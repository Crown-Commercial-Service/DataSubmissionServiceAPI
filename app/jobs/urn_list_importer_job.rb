require 'tempfile'
require 'csv'
require 'aws-sdk-s3'
require 'rubyXL'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class UrnListImporterJob < ApplicationJob
  class AlreadyImported < StandardError; end

  class InvalidFormat < StandardError; end

  REQUIRED_COLUMNS = ['URN', 'CustomerName', 'PostCode', 'Sector'].freeze

  discard_on ActiveJob::DeserializationError
  discard_on AlreadyImported

  discard_on InvalidFormat do |job, _error|
    job.arguments.first.update!(aasm_state: :failed)
  end

  retry_on Aws::S3::Errors::ServiceError

  def perform(urn_list)
    raise AlreadyImported unless urn_list.pending?

    downloader = AttachedFileDownloader.new(urn_list.excel_file)
    downloader.download!

    convert_to_csv(downloader.temp_file.path)

    customers = customers_from_csv

    soft_delete!(customers)
    upsert!(customers)

    remove_published_column(urn_list, downloader.temp_file.path)

    urn_list.update!(aasm_state: :processed)

    downloader.temp_file.close
    downloader.temp_file.unlink
  end

  private

  def convert_to_csv(path)
    command = "in2csv --sheet=\"Customers\" --locale=en_GB --blanks --skipinitialspace #{path}"
    command += " | csvcut -c 'URN,CustomerName,PostCode,Sector,Published'"
    command += " > \"#{csv_temp_file.path}\""

    result = Ingest::CommandRunner.new(command).run!
    raise InvalidFormat unless result.successful?
  end

  def csv_temp_file
    @csv_temp_file ||= Tempfile.new('customer')
  end

  def customers_from_csv
    customers = []

    CSV.foreach(csv_temp_file, headers: true) do |row|
      raise InvalidFormat unless (row.headers & REQUIRED_COLUMNS) == REQUIRED_COLUMNS

      customers << Customer.new(
        name: row['CustomerName'],
        urn: row['URN'].to_i,
        postcode: row['PostCode'],
        sector: (row['Sector'] == 'Central Government' ? :central_government : :wider_public_sector),
        deleted: false,
        published: (row['Published'] == 'False' ? false : true)
      )
    end

    csv_temp_file.close
    csv_temp_file.unlink

    customers
  end

  def upsert!(customers)
    Customer.transaction do
      Customer.import(
        customers,
        batch_size: 100,
        on_duplicate_key_update: {
          conflict_target: [:urn],
          columns: %i[name postcode sector deleted published]
        }
      )
    end
  end

  def soft_delete!(customers)
    existing_urns = Customer.pluck(:urn)
    importing_urns = customers.map(&:urn)

    urns_to_be_deleted = existing_urns - importing_urns

    Customer.where(urn: urns_to_be_deleted).update(deleted: true)
  end

  def remove_published_column(urn_list, path)
    workbook = RubyXL::Parser.parse(path)
    worksheet = workbook[0]
    row_count = worksheet.sheet_data.rows.size

    remove_secret_urns(worksheet, row_count)

    worksheet.delete_column(4)

    file_name = urn_list.excel_file.filename
    workbook.write(path)
    urn_list.excel_file.purge
    urn_list.excel_file.attach(io: File.open(path), filename: file_name)
  end

  def remove_secret_urns(worksheet, row_count)
    row_num = 1

    until row_num == row_count
      row = worksheet[row_num]
      break if row.nil?

      if row[4]&.value&.zero?
        worksheet.delete_row(row_num)
      else
        row_num += 1
      end
    end
  end
end

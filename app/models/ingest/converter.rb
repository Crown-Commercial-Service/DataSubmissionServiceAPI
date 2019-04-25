require 'csv'

module Ingest
  ##
  # Takes a +Download+ from Ingest::SubmissionFileDownloader and returns
  # a +Rows+ object for both invoices and orders, comprising the
  # row +data+ (as a CSV enumerable), +row_count+, +sheet_name+
  # and +type+ (invoice or order)
  #
  # +rows+ contains the combined row counts for both sheets
  class Converter
    attr_reader :download

    Rows = Struct.new(:data, :row_count, :sheet_name, :type)

    def initialize(download)
      @download = download
    end

    def rows
      @rows ||= invoices.row_count + orders.row_count
    end

    def invoices
      @invoices ||= fetch_sheet('invoice')
    end

    def orders
      @orders ||= fetch_sheet('order')
    end

    def sheets
      @sheets ||= begin
                    response = Ingest::CommandRunner.new("in2csv --names #{download.temp_file}").run!
                    response.stdout if response.successful?
                  end
    end

    private

    def fetch_sheet(type)
      sheet_temp_file = download.temp_file + '_' + type + '.csv'
      sheet_name = type == 'invoice' ? invoice_sheet_name : order_sheet_name

      command = "in2csv -l --sheet=\"#{sheet_name}\" --locale=en_GB --blanks --skipinitialspace #{download.temp_file}"
      command += " > #{sheet_temp_file}"
      Ingest::CommandRunner.new(command).run!

      row_count = fetch_row_count(sheet_temp_file)

      Rows.new(
        CSV.foreach(sheet_temp_file, headers: true),
        row_count,
        sheet_name,
        type
      )
    end

    def fetch_row_count(file)
      command = "wc -l < #{file} | xargs"
      row_count = Ingest::CommandRunner.new(command).run!.stdout.first.to_i
      row_count -= 1 unless row_count.zero? # Handle empty results
      row_count
    end

    def invoice_sheet_name
      @invoice_sheet_name ||= sheets.find { |sheet| sheet.match(/(booking|finance|management|invoice)/i) }
    end

    def order_sheet_name
      @order_sheet_name ||= sheets.find { |sheet| sheet.match(/(order|contract)/i) }
    end
  end
end

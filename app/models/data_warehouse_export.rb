class DataWarehouseExport < ApplicationRecord
  EARLIEST_RANGE_FROM = Time.new(2000, 1, 1).utc.freeze

  after_initialize :set_date_range

  def self.generate!
    new.tap do |export|
      ActiveRecord::Base.transaction(isolation: :repeatable_read) do
        files = export.generate_files
        Export::S3Upload.new(files).perform
        export.save!
      end
    end
  end

  def generate_files
    {
      "tasks_#{timestamp}.csv" => tasks_export_file,
      "submissions_#{timestamp}.csv" => submissions_export_file,
      "invoices_#{timestamp}.csv" => invoices_export_file,
      "contracts_#{timestamp}.csv" => contracts_export_file
    }.compact
  end

  def date_range
    (range_from..range_to)
  end

  private

  def tasks_export_file
    Export::Relation.new(Export::Tasks::Extract.all_relevant(date_range)).run
  end

  def submissions_export_file
    Export::Relation.new(Export::Submissions::Extract.all_relevant(date_range)).run
  end

  def invoices_export_file
    Export::Relation.new(Export::Invoices::Extract.all_relevant(date_range)).run
  end

  def contracts_export_file
    Export::Relation.new(Export::Contracts::Extract.all_relevant(date_range)).run
  end

  def set_date_range
    self.range_from ||= last_export_date || EARLIEST_RANGE_FROM
    self.range_to   ||= Time.zone.now
  end

  def timestamp
    range_to.strftime('%Y%m%d_%H%M%S')
  end

  def last_export_date
    DataWarehouseExport.maximum(:range_to)
  end
end

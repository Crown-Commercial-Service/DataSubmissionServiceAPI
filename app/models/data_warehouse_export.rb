class DataWarehouseExport < ApplicationRecord
  EARLIEST_RANGE_FROM = Time.new(2000, 1, 1).utc.freeze

  after_initialize :set_date_range

  def self.generate!
    new.tap do |export|
      ActiveRecord::Base.transaction(isolation: :repeatable_read) do
        export.generate_files
        export.save!
      end
    end
  end

  def generate_files
    [
      Export::Relation.new(Export::Tasks::Extract.all_relevant(date_range)).run,
      Export::Relation.new(Export::Submissions::Extract.all_relevant(date_range)).run,
      Export::Relation.new(Export::Invoices::Extract.all_relevant(date_range)).run,
      Export::Relation.new(Export::Contracts::Extract.all_relevant(date_range)).run
    ]
  end

  def date_range
    (range_from..range_to)
  end

  private

  def set_date_range
    self.range_from ||= last_export_date || EARLIEST_RANGE_FROM
    self.range_to   ||= Time.zone.now
  end

  def last_export_date
    DataWarehouseExport.maximum(:range_to)
  end
end

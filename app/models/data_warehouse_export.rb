class DataWarehouseExport < ApplicationRecord
  EARLIEST_RANGE_FROM = Time.new(2000, 1, 1).utc.freeze

  after_initialize :set_date_range

  def self.generate!
    new.tap do |export|
      ActiveRecord::Base.transaction(isolation: :repeatable_read) do
        Export::Anything.new(Export::Tasks::Extract.all_relevant(export.date_range)).run
        Export::Anything.new(Export::Submissions::Extract.all_relevant(export.date_range)).run
        Export::Anything.new(Export::Invoices::Extract.all_relevant(export.date_range)).run
        Export::Anything.new(Export::Contracts::Extract.all_relevant(export.date_range)).run

        export.save!
      end
    end
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

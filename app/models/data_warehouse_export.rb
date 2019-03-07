class DataWarehouseExport < ApplicationRecord
  EARLIEST_RANGE_FROM = Time.new(2000, 1, 1).utc.freeze

  before_create :set_date_range

  def run
    Export::Anything.new(Export::Tasks::Extract.all_relevant).run
    Export::Anything.new(Export::Submissions::Extract.all_relevant).run
    Export::Anything.new(Export::Invoices::Extract.all_relevant).run
    Export::Anything.new(Export::Contracts::Extract.all_relevant).run
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

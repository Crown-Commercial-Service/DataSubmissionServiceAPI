require 'csv'
require 'supplier_import_row'

class SupplierImport
  def initialize(csv_data)
    @rows = CSV.parse(csv_data, headers: true, header_converters: :symbol)
  end

  def run!
    @rows.each do |row|
      SupplierImportRow.new(row.to_h).import!
    end
  end
end

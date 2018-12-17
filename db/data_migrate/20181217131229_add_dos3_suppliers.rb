# Creates DOS3 suppliers and their agreements
#
# Execute with:
#
#   rails runner db/data_migrate/20181217131229_add_dos3_suppliers.rb
#

require 'csv'

suppliers_csv_path = Rails.root.join('db', 'data_migrate', '20181217131229_add_dos3_suppliers.csv')
csv = CSV.read(suppliers_csv_path, headers: true, header_converters: :symbol)
dos3 = Framework.find_by!(short_name: 'RM1043.5')

csv.each do |row|
  supplier = Supplier.find_or_create_by!(salesforce_id: row.fetch(:salesforce_id)) do |s|
    s.coda_reference = row.fetch(:coda_reference)
    s.name = row.fetch(:supplier_name)
  end

  agreement = supplier.agreements.find_or_create_by!(framework_id: dos3.id)

  if agreement.lot_numbers.include? row.fetch(:lot_number)
    puts "Warning: Supplier #{supplier.name} (#{supplier.salesforce_id}) already on lot #{row.fetch(:lot_number)}"
  else
    framework_lot = dos3.lots.find_by(number: row.fetch(:lot_number))
    puts "Adding supplier #{supplier.name} (#{supplier.salesforce_id}) to lot #{row.fetch(:lot_number)}"
    agreement.agreement_framework_lots.create!(framework_lot: framework_lot)
  end
end

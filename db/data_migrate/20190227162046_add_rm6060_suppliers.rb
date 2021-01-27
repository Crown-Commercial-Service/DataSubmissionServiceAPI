# Creates RM606 suppliers and their agreements
#
# Execute with:
#
#   rails runner db/data_migrate/20190227162046_add_rm6060_suppliers.rb
#
require 'csv'

suppliers_csv_path = Rails.root.join('db', 'data_migrate', '20190227162046_add_rm6060_suppliers.csv')
csv = CSV.read(suppliers_csv_path, headers: true, header_converters: :symbol)
framework = Framework.find_by!(short_name: 'RM6060')

csv.each do |row|
  supplier = Supplier.find_or_create_by!(salesforce_id: row.fetch(:salesforce_id)) do |s|
    s.name = row.fetch(:supplier_name)
  end

  agreement = supplier.agreements.find_or_create_by!(framework_id: framework.id)

  if agreement.lot_numbers.include? row.fetch(:lot_number)
    puts "Warning: Supplier #{supplier.name} (#{supplier.salesforce_id}) already on lot #{row.fetch(:lot_number)}"
  else
    framework_lot = framework.lots.find_by(number: row.fetch(:lot_number))
    puts "Adding supplier #{supplier.name} (#{supplier.salesforce_id}) to lot #{row.fetch(:lot_number)}"
    agreement.agreement_framework_lots.create!(framework_lot: framework_lot)
  end
end

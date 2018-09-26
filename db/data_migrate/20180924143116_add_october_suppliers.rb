require 'csv'

october_suppliers_csv_path = Rails.root.join('db', 'data_migrate', '20180924143116_add_october_suppliers.csv')
csv = CSV.read(october_suppliers_csv_path, headers: true, header_converters: :symbol)
suppliers = csv.map do |row|
  Supplier.create!(name: row[:supplier_name], coda_reference: row[:coda_reference])
end
# Output lookup hash for supplier IDs to be used in user seeding
puts suppliers.each_with_object({}) { |supplier, hash| hash[supplier.name] = supplier.id }

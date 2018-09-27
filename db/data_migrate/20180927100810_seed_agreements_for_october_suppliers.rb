require 'csv'

frameworks_to_suppliers_csv = Rails.root.join('db', 'data_migrate', '20180927100810_frameworks_to_suppliers.csv')

CSV.read(frameworks_to_suppliers_csv, headers: true, header_converters: :symbol).each do |row|
  framework = Framework.find_by!(short_name: row[:framework_short_name])
  supplier = Supplier.find_by!(name: row[:supplier_name])

  supplier.agreements.find_or_create_by!(framework: framework)
end

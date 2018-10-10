# Backfill Salesforce ids for suppliers as of October submission window:
#
#   runner db/data_migrate/20181010114354_seed_supplier_salesforce_ids.rb
#
require 'csv'

salesforce_ids_filepath = Rails.root.join('db', 'data_migrate', '20181010114354_seed_supplier_salesforce_ids.csv')
csv = CSV.read(salesforce_ids_filepath, headers: true)

csv.each do |row|
  Supplier.find_by(name: row['supplier_name']).update(salesforce_id: row['salesforce_id'])
end

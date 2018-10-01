# Execute with:
#
#   rails runner db/data_migrate/20181001100230_import_inactive_customers.rb
#
require 'csv'
require 'progress_bar'

puts 'Reading CSV file...'
customers_csv_path = Rails.root.join('db', 'data_migrate', '20181001100230_import_inactive_customers.csv')
csv = CSV.read(customers_csv_path, headers: true, header_converters: :symbol)

puts 'Importing customers...'
bar = ProgressBar.new(csv.count)
csv.each do |customer_row|
  postcode = customer_row[:postcode] == 'XXXX' ? nil : customer_row[:postcode].strip

  customer = Customer.find_or_initialize_by(urn: customer_row[:urn])
  customer.postcode = postcode
  customer.sector = customer_row[:sector].strip.parameterize.underscore
  customer.name = customer_row[:customername].strip
  customer.save!

  bar.increment!
end

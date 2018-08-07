require 'csv'
require 'progress_bar'

puts 'Reading CSV file...'
customers_csv_path = Rails.root.join('db', 'data_migrate', '20180807095900_customers.csv')
csv = CSV.read(customers_csv_path, headers: true, header_converters: :symbol)

puts 'Importing customers...'
bar = ProgressBar.new(csv.count)
csv.each do |customer_row|
  postcode = customer_row[:postcode] == 'XXXX' ? nil : customer_row[:postcode].strip

  Customer.find_or_create_by(urn: customer_row[:urn]) do |customer|
    customer.postcode = postcode
    customer.sector = customer_row[:sector].strip.parameterize.underscore
    customer.name = customer_row[:customername].strip
  end

  bar.increment!
end

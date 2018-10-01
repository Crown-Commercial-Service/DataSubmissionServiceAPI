# Use against a production DB cut to make a new customers file to STDOUT from
# a 50K+ new-big-source.csv containing only new customers

require 'csv'
require 'progress_bar'

warn 'Reading CSV file...'
customers_csv_path = Rails.root.join('db', 'data_migrate', 'new-big-customer.csv')
csv = CSV.read(customers_csv_path, headers: true, header_converters: :symbol)

warn 'Filtering customers...'
bar = ProgressBar.new(csv.count)

def needs_importing?(customer_row)
  # We're only interested in customers that don't already exist and that have
  # non-internal URN numbers (real URN numbers appear to start at 10000000, with
  # URNs below that being used for testing purposes)
  !Customer.exists?(urn: customer_row[:urn]) && customer_row[:urn].to_i > 10000000
end

def customers_header(customers_csv_path)
  File.open(customers_csv_path, &:readline)
end

puts customers_header(customers_csv_path)
csv.each do |customer_row|
  puts CSV.generate_line(customer_row) if needs_importing?(customer_row)
  bar.increment!
end

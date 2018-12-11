# Import lots data for all active Frameworks
#
# Execute with:
#
#   rails runner db/data_migrate/20181211142840_import_framework_lots.rb
#
require 'csv'

puts 'Reading CSV file...'
customers_csv_path = Rails.root.join('db', 'data_migrate', '20181211142840_import_framework_lots.csv')
csv = CSV.read(customers_csv_path, headers: true, header_converters: :symbol)

puts 'Importing framework lots...'
csv.each do |row|
  if (framework = Framework.find_by(short_name: row.fetch(:framework_number)))
    if framework.lots.find_by(number: row.fetch(:lot_number))
      puts "Lot #{row.fetch(:lot_number)} already exists on #{framework.short_name}"
    else
      puts "Adding lot #{row.fetch(:lot_number)} to #{framework.short_name}"
      framework.lots.create!(number: row.fetch(:lot_number), description: row.fetch(:lot_description))
    end
  else
    puts "Framework #{row.fetch(:framework_number)} not found"
  end
end

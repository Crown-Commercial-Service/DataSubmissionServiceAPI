# Import agreement lots data for all supplier agreements
#
# Execute with:
#
#   rails runner db/data_migrate/20181211145424_import_agreement_framework_lots.rb
#
require 'csv'

puts 'Reading CSV file...'
customers_csv_path = Rails.root.join('db', 'data_migrate', '20181211145424_import_agreement_framework_lots.csv')
csv = CSV.read(customers_csv_path, headers: true, header_converters: :symbol)

puts 'Importing agreement lots...'
csv.each do |row|
  if (supplier = Supplier.find_by(salesforce_id: row.fetch(:salesforce_id)))
    if (framework = Framework.find_by(short_name: row.fetch(:framework_number)))
      agreement = supplier.agreement_for_framework(framework)

      if agreement.lot_numbers.include?(row.fetch(:lot_number))
        puts "Supplier #{supplier.name} (#{supplier.salesforce_id}) already allocated to lot" \
             " #{row.fetch(:lot_number)} on #{row.fetch(:framework_number)}"
      else
        framework_lot = framework.lots.find_by(number: row.fetch(:lot_number))
        puts "Adding supplier #{supplier.name} (#{supplier.salesforce_id}) to lot #{row.fetch(:lot_number)} on" \
             " #{row.fetch(:framework_number)}"
        agreement.agreement_framework_lots.create!(framework_lot: framework_lot)
      end
    end
  else
    puts "Supplier #{row.fetch(:supplier_name)} (#{row.fetch(:salesforce_id)}) not found"
  end
end

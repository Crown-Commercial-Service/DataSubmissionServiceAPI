# The CSV file was generated with the help of db/data_migrate/fetch_full_dmsids.rb
#
# Execute with:
#
#   rails runner db/data_migrate/20190404130719_fix_dmsid.rb
#

require 'csv'
require 'progress_bar'

puts 'Reading CSV file...'
corrections_csv_path = Rails.root.join('db', 'data_migrate', '20190404130719_fix_dmsid.csv')
csv = CSV.read(corrections_csv_path, headers: true, header_converters: :symbol)

puts 'Importing corrected Digital Marketplace Service IDs...'
bar = ProgressBar.new(csv.count)

SubmissionEntry.transaction do
  csv.each do |row|
    entry = SubmissionEntry.find(row[:entry_id])
    data = entry.data
    data['Digital Marketplace Service ID'] = row[:dmsid]

    # rubocop:disable Rails/SkipsModelValidations
    entry.update_column(:data, data)
    # rubocop:enable Rails/SkipsModelValidations

    bar.increment!
  end
end

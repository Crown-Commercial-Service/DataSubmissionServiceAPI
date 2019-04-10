# The CSV file was generated with the help of db/data_migrate/correct_american_data_formats.rb
#
# Execute with:
#
#   rails runner db/data_migrate/20190408132216_fix_american_dates.rb
#

require 'csv'
require 'progress_bar'

puts 'Reading CSV file...'
corrections_csv_path = Rails.root.join('db', 'data_migrate', '20190408132216_fix_american_dates.csv')

puts 'Importing corrected dates...'
bar = ProgressBar.new(403372)

SubmissionEntry.transaction do
  CSV.foreach(corrections_csv_path, headers: true, header_converters: :symbol) do |row|
    entry = SubmissionEntry.find(row[:entry_id])

    # https://gist.github.com/just3ws/d002243983ae00886c37 (to avoid 'eval')
    corrected_values = JSON.parse(
      '{' +
      row[:corrected_values]
      .gsub(/^{|}$/, '')
      .split(', ')
      .map { |pair| pair.split('=>') }
      .map { |k, v| [k.gsub(/^:(\w*)/, '"\1"'), v == 'nil' ? 'null' : v].join(': ') }
      .join(', ') +
      '}'
    )

    data = entry.data.merge(corrected_values)

    # rubocop:disable Rails/SkipsModelValidations
    entry.update_column(:data, data)
    # rubocop:enable Rails/SkipsModelValidations

    bar.increment!
  end
end

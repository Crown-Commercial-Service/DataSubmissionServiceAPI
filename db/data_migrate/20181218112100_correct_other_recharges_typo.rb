# Set the coda reference and lot details for RM1043.5
#
# Execute with:
#
#   rails runner db/data_migrate/20181218112100_correct_other_recharges_typo.rb
#

require 'progress_bar'

puts 'Correcting Recharges to Re-charges'
incorrect_data = SubmissionEntry.where("data->>'Spend Code' = 'Other Recharges'")
bar = ProgressBar.new(incorrect_data.count)

incorrect_data.find_each do |submission_entry|
  submission_entry.data['Spend Code'] = 'Other Re-charges'
  submission_entry.save!
  bar.increment!
end

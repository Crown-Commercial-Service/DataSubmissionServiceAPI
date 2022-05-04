# Backfill management charges for all validated invoice entries. Run with:
#
#   rails runner db/data_migrate/20181015092520_backfill_submission_entries_management_charge.rb
#
require 'progress_bar'

entries_to_backfill = SubmissionEntriesStage.invoices.validated.includes(:framework).where(management_charge: nil)
progress_bar = ProgressBar.new(entries_to_backfill.count)

entries_to_backfill.find_each do |submission_entry|
  framework_definition = submission_entry.framework.definition
  submission_entry.update! management_charge: framework_definition.management_charge(submission_entry.total_value)
  progress_bar.increment!
rescue NoMethodError
  puts "Could not calculate charge for #{submission_entry.id}"
end

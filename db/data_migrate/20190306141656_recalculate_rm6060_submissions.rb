# Re-calculates the management charge on all RM6060 submissons that have had
# their management charge calculated, i.e. those that are in_review or completed.
#
# Execute with:
#
#   rails runner db/data_migrate/20190306141656_recalculate_rm6060_submissions.rb
#
rm6060 = Framework.find_by(short_name: 'RM6060')
submissions = Submission.where(framework: rm6060, aasm_state: %i[in_review completed])

submissions.each do |submission|
  puts "Submission #{submission.id} charge: #{submission.management_charge}"
  submission.entries.invoices.find_each do |entry|
    entry.update! management_charge: rm6060.definition.calculate_management_charge(entry)
  end

  submission.entries_stages.invoices.find_each do |entry|
    entry.update! management_charge: rm6060.definition.calculate_management_charge(entry)
  end
  puts "Recalculated charge: #{submission.management_charge}"
end

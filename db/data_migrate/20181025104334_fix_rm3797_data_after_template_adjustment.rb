# Updates the ingested data for RM3797 to reflect the adjustment we've made to
# the template (removed a single-quote-as-apostrophe)
#
# Execute with:
#
#   rails runner db/data_migrate/20181025104334_fix_rm3797_data_after_template_adjustment.rb
#
rm3797 = Framework.where(short_name: 'RM3797')
submissions = Submission.where(framework: rm3797)

submissions.each do |submission|
  submission.entries.each do |entry|
    entry.data['Publisher Name'] = entry.data["Publisher's Name"]
    entry.data.delete("Publisher's Name")
    entry.save!
  end
end

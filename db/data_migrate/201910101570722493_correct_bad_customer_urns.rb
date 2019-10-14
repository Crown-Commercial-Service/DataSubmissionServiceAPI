# Execute with:
#
#   rails runner db/data_migrate/201910101570722493_correct_bad_customer_urns.rb
#

URN_HASH = {
  'PU-20-0116' => 10002280,
  'CCS-WHITEFRI' => 10562530,
  'TO318/BHT/MM' => 10000416,
  'UCLH-2503' => 10010982,
  'GMATIT002A' => 10035694,
  'URN' => 10041455,
  '10025639.715176' => 10025639,
  '10025949_x000D_' => 10025949,
  '10005392_x000D_' => 10005392
}.freeze

SubmissionEntry.transaction do
  URN_HASH.each do |bad_urn, good_urn|
    submission_entries = SubmissionEntry.where('data @> ?', { 'Customer URN': bad_urn }.to_json)

    submission_entries.find_each do |submission_entry|
      submission_entry.customer_urn = good_urn
      submission_entry.data['Customer URN'] = good_urn
      submission_entry.save
    end
  end
end

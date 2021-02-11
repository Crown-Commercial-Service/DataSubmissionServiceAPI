# Add new frameworks to frameworks table
#
# Execute with:
#
#   rails runner db/data_migrate/20190321170000_seed_new_frameworks.rb
#

DOS_LOTS = {
  '1' => 'Outcomes',
  '2' => 'Specialists',
  '3' => 'User research studios',
  '4' => 'User research participants'
}.freeze

NEW_GCLOUD_LOTS = {
  '1' => 'Cloud Hosting',
  '2' => 'Cloud Software',
  '3' => 'Cloud Support'
}.freeze

OLD_GCLOUD_LOTS = {
  '1' => 'Infrastructure as a Service (IaaS)',
  '2' => 'Platform as a Service (PaaS)',
  '3' => 'Software as a Service',
  '4' => 'Specialist Cloud Services'
}.freeze

NEW_FRAMEWORK_DATA = [
  ['RM1043iii', 400141, 'Digital Outcomes and Specialists', DOS_LOTS],
  ['RM1043iv', 400141, 'Digital Outcomes & Specialists 2', DOS_LOTS],
  [
    'RM3788', 401154, 'Wider Public Services Legal Services',
    {
      '1' =>	'Regional Legal Services',
      '2a' =>	'Full Service Law Firms - England and Wales',
      '2b' =>	'Full Service Law Firms - Scotland',
      '2c' =>	'Full Service Law Firms - Northern Ireland',
      '3' =>	'Property and Construction',
      '4' =>	'Transport Rail'
    }
  ],
  ['RM1557.10', 400156, 'G-Cloud 10', NEW_GCLOUD_LOTS],
  ['RM1557ix',  400155, 'G-Cloud 9', NEW_GCLOUD_LOTS],
  ['RM1557vii', 400116, 'G-Cloud 7', OLD_GCLOUD_LOTS],
  ['RM1557viii', 400116, 'G-Cloud 8', OLD_GCLOUD_LOTS]
].freeze

NEW_FRAMEWORK_DATA.each do |short_name, name, lots|
  framework = Framework.create!(short_name: short_name, name: name)

  lots.each_pair do |number, description|
    framework.lots.create!(number: number, description: description)
  end
end

# Add new frameworks to frameworks table
#
# Execute with:
#
#   rails runner db/data_migrate/20190321170000_seed_new_frameworks.rb
#

NEW_FRAMEWORK_DATA = [
  ['RM1043iii',  400141, 'Digital Outcomes and Specialists'],
  ['RM1043iv',   400141, 'Digital Outcomes & Specialists 2'],
  ['RM3788',     401154, 'Wider Public Services Legal Services'],
  ['RM1557.10',  400156, 'G-Cloud 10'],
  ['RM1557ix',   400155, 'G-Cloud 9'],
  ['RM1557vii',  400116, 'G-Cloud 7'],
  ['RM1557viii', 400116, 'G-Cloud 8']
].freeze

NEW_FRAMEWORK_DATA.each do |short_name, coda_reference, name|
  Framework.create!(short_name: short_name, coda_reference: coda_reference, name: name)
end

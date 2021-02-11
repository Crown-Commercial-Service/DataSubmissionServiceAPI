OCTOBER_FRAMEWORK_DATA = [
  ['CM/OSG/05/3565', 'Laundry Services - Wave 2'],
  ['RM1031',         'Laundry and Linen Services'],
  ['RM1070',         'Vehicle Purchase'],
  ['RM3710',         'Vehicle Lease and Fleet Management'],
  ['RM3754',         'Vehicle Telematics'],
  ['RM3767',         'Supply and Fit of Tyres'],
  ['RM3772',         'Specialist Laundry Services (for Surgical Drapes, Gowns and Packs)'],
  ['RM3797',         'Journal Subscriptions'],
  ['RM807',          'Vehicle Hire'],
  ['RM849',          'Laundry & Linen Services Framework'],
  ['RM858',          'Pan Govt Vehicle Leasing & Fleet Outsource Solutions']
].freeze

OCTOBER_FRAMEWORK_DATA.each do |short_name, name|
  Framework.create!(short_name: short_name, name: name)
end

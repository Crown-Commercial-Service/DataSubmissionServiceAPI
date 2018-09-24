OCTOBER_FRAMEWORK_DATA = [
  ['CM/OSG/05/3565', 402700, 'Laundry Services - Wave 2'],
  ['RM1031',         400447, 'Laundry and Linen Services'],
  ['RM1070',         402440, 'Vehicle Purchase'],
  ['RM3710',         402420, 'Vehicle Lease and Fleet Management'],
  ['RM3754',         402470, 'Vehicle Telematics'],
  ['RM3767',         402450, 'Supply and Fit of Tyres'],
  ['RM3772',         400448, 'Specialist Laundry Services (for Surgical Drapes, Gowns and Packs)'],
  ['RM3797',         401513, 'Journal Subscriptions'],
  ['RM807',          402430, 'Vehicle Hire'],
  ['RM849',          400412, 'Laundry & Linen Services Framework'],
  ['RM858',          402420, 'Pan Govt Vehicle Leasing & Fleet Outsource Solutions']
].freeze

OCTOBER_FRAMEWORK_DATA.each do |short_name, coda_reference, name|
  Framework.create!(short_name: short_name, coda_reference: coda_reference, name: name)
end

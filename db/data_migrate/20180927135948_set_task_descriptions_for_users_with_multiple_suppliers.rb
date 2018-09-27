# NOTE: To be run AFTER the September tasks have been generated
SUPPLIER_WITH_SHARED_USERS = [
  'Berendsen UK Limited',
  'Central Laundry',
  'Pennine Acute Hospitals NHS Trust',
  'Synergy Health PLC',
  'Synergy Health Managed Services Ltd',
  'Royal Devon and Exeter Hospital',
  'Royal Devon & Exeter NHS Foundation Trust',
  'Salisbury Healthcare NHS Trust',
  'ISUZU (UK) LTD',
  'SUBARU (UK) LTD',
  'SEAT UK Ltd',
  'Skoda Auto UK',
  'Volkswagen (UK) Ltd',
  'Volkswagen Commercial Vehicles',
  'ALD Automotive Ltd',
  'Fraikin Ltd',
  'Hitachi Capital Vehicle Solutions Ltd',
  'Inchcape Fleet Solutions',
  'Leasedrive Limited',
  'Leasedrive Velo',
  'LeasePlan UK Limited',
  'Lex Autolease',
].freeze

SUPPLIER_WITH_SHARED_USERS.each do |supplier_name|
  supplier = Supplier.find_by!(name: supplier_name)
  puts "Setting task description for #{supplier_name}'s September tasks"
  supplier.tasks.where(period_month: 9, period_year: 2018).update(description: supplier.name)
end

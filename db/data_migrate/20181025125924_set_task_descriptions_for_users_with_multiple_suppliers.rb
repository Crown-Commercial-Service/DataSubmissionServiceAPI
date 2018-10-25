# NOTE: To be run AFTER the October tasks have been generated
#
# rails runner db/data_migrate/20181025125924_set_task_descriptions_for_users_with_multiple_suppliers.rb
SUPPLIER_WITH_SHARED_USERS = [
  'ISUZU (UK) LTD',
  'Leasedrive Limited',
  'Leasedrive Velo',
  'Royal Devon and Exeter Hospital',
  'Royal Devon & Exeter NHS Foundation Trust',
  'SEAT UK Ltd',
  'Skoda Auto UK',
  'SUBARU (UK) LTD',
  'Synergy Health Managed Services Ltd',
  'Synergy Health PLC',
  'Volkswagen Commercial Vehicles',
  'Volkswagen (UK) Ltd'
].freeze

SUPPLIER_WITH_SHARED_USERS.each do |supplier_name|
  supplier = Supplier.find_by!(name: supplier_name)
  puts "Setting task description for #{supplier_name}'s October tasks"
  supplier.tasks.where(period_month: 10, period_year: 2018).update(description: supplier.name)
end

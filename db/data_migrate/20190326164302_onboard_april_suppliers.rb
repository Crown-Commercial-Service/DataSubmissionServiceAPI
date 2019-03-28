# Onboards suppliers for April frameworks
#
# Execute with:
#
#   rails runner db/data_migrate/20190326164302_onboard_april_suppliers.rb
#

Import::FrameworkSuppliers.new(Rails.root.join('db', 'data_migrate', '20190326164302_onboard_april_suppliers.csv')).run

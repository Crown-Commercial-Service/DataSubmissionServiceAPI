# - Remove supplier `4e88c390-ea7d-4eb9-b39b-adbf6337628a`, name 'test supplier',
#   which will also remove its agreement and associated tasks (no submissions at time
#   of writing, but would also cascade those were any to exist)
#
# Execute with:
#
#   rails runner db/data_migrate/20190219113200_delete_test_supplier.rb
#

Supplier.find('4e88c390-ea7d-4eb9-b39b-adbf6337628a').destroy

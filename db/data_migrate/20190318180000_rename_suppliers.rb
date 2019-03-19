# Rename two suppliers
#
# Execute with:
#
#   rails runner db/data_migrate/20190318180000_rename_suppliers.rb
#

piaggio = Supplier.find('efc792a5-104c-4934-a379-bc23de5a7b7b')
piaggio.update(name: 'PIAGGIO LIMITED')

faculty = Supplier.find('e11b2b49-1db4-4bab-9c23-2a64b8d8dd0b')
faculty.update(name: 'FACULTY SCIENCE LIMITED')

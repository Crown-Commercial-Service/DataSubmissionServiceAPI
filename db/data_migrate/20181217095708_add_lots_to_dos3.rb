# Set the lot details for RM1043.5
#
# Execute with:
#
#   rails runner db/data_migrate/20181217095708_add_lots_to_dos3.rb
#

dos3 = Framework.find_by!(short_name: 'RM1043.5')
dos3.save!

{
  1 => 'Digital outcomes',
  2 => 'Digital specialists',
  3 => 'User research studios',
  4 => 'User research participants'
}.each_pair do |number, description|
  dos3.lots.create!(number: number, description: description)
end

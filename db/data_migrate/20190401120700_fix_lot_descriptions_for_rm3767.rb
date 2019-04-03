# Fix lot descriptions for RM3767
#
# Execute with:
#
#   rails runner db/data_migrate/20190401120700_fix_lot_descriptions_for_RM3767.rb
#

RM3767_LOTS = {
  '1' => 'The supply and fit of tyres and associated services to the Police and emergency services',
  '2' => 'The supply and fit of tyres and associated services to central Government and the wider public sector',
}.freeze

rm3767 = Framework.find_by!(short_name: 'RM3767')

RM3767_LOTS.each_pair do |number, description|
  rm3767.lots.find_by!(number: number).update!(description: description)
end

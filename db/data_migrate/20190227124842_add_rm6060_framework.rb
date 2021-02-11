# Data migration to add RM6060 to database. Run with:
#
#   rails runner db/data_migrate/20190227124842_add_rm6060_framework.rb
#
exit if Framework.exists?(short_name: 'RM6060')

rm6060 = Framework.create!(
  short_name: 'RM6060',
  name: 'Vehicle Purchase'
)

# rubocop:disable Metrics/LineLength
{
  1 => 'Passenger Cars (including 4x4 variants)',
  2 => 'Light to medium commercial vehicles (including car derived vans, 4x4 variants & minibuses) up to but not including 7.5 tonnes',
  3 => 'Medium to heavy Commercial Vehicles 7.5 tonnes and above',
  4 => 'Motorcycles (including scooters and quad bikes)',
  5 => 'Buses and Coaches',
  6 => 'Blue light vehicles (including passenger vehicles, 4x4 variants, all-terrain vehicles, motorcycles, scooters and quad bikes)',
  7 => 'Blue light: light to medium commercial vehicles (including car derived vans, 4x4 variants & minibuses) up to but not including 7.5 tonnes'
}.each_pair do |number, description|
  rm6060.lots.create!(number: number, description: description)
end
# rubocop:enable Metrics/LineLength

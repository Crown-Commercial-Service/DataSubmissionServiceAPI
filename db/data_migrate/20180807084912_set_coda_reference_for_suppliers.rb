NAME_TO_CODA_REFERENCE_MAPPING = {
  'Addleshaw Goddard LLP' => 'C000976',
  'Ashurst LLP' => 'C005187',
  'DLA Piper LLP' => 'C002107',
  'Eversheds Sutherland (International) LLP' => 'C000941',
  'Linklaters LLP' => 'C002112',
  'Norton Rose Fulbright LLP' => 'C002119',
  'Osborne Clarke LLP' => 'C009841',
  'Stephenson Harwood' => 'C005196',
  'Bond Dickinson LLP' => 'C000940',
  'Burges Salmon LLP' => 'C000977',
  'DAC Beachcroft LLP' => 'C009492',
  'Dentons UK MEA LLP' => 'C000851',
  'Gowling WLG (UK) LLP' => 'C000855',
  'Mills & Reeve LLP' => 'C002031',
  'Pinsent Mason' => 'C000853',
  'PricewaterhouseCoopers LLP' => 'C000568',
  'TLT LLP' => 'C009493',
  'Bevan Brittan LLP' => 'C000850',
  'Browne Jacobson LLP' => 'C005191',
  'Field Fisher Waterhouse' => 'C000911',
  'Hogan Lovells International LLP' => 'C002113',
  'Simmons & Simmons LLP' => 'C000917',
  'Slaughter & May' => 'C002123',
  'BRYAN CAVE LEIGHTON PAISNER LLP' => 'C002101',
  'Clifford Chance LLP' => 'C009889',
  'Freshfields Bruckhaus Deringer' => 'C002108',
}.freeze

NAME_TO_CODA_REFERENCE_MAPPING.each_pair do |name, coda_reference|
  Supplier.find_by!(name: name).update!(coda_reference: coda_reference)
end

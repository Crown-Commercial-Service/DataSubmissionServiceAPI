
SHORT_NAME_TO_CODA_REFERENCE_MAPPING = {
  'RM3786' => '401108',
  'RM3756' => '401148',
  'RM3787' => '401149'
}.freeze

SHORT_NAME_TO_CODA_REFERENCE_MAPPING.each_pair do |short_name, coda_reference|
  Framework.find_by!(short_name: short_name).update!(coda_reference: coda_reference)
end

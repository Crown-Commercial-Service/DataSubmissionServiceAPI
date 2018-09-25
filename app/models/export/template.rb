module Export
  module Template
    # Mapping direction: destination_field in export => source_field from submission_entries.data
    LEGAL_FRAMEWORK = {
      'CustomerURN'      => 'Customer URN',
      'CustomerName'     => 'Customer Organisation Name',
      'CustomerPostCode' => 'Customer Post Code',
      'InvoiceDate'      => 'Customer Invoice Date',
      'InvoiceNumber'    => 'Customer Invoice Number',
    }.freeze

    BY_FRAMEWORK = {
      'RM3786' => LEGAL_FRAMEWORK,
      'RM3756' => LEGAL_FRAMEWORK,
      'RM3787' => LEGAL_FRAMEWORK,
    }.freeze

    def self.source_field_for(dest_field_name, framework_short_name)
      template_fields = BY_FRAMEWORK.fetch(framework_short_name)
      template_fields[dest_field_name]
    end
  end
end

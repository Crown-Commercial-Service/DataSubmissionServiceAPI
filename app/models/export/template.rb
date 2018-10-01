module Export
  module Template
    # Mapping direction: destination_field in export => source_field from submission_entries.data
    LEGAL_FRAMEWORK = {
      'CustomerURN'             => 'Customer URN',
      'CustomerName'            => 'Customer Organisation Name',
      'CustomerPostCode'        => 'Customer Post Code',
      'InvoiceDate'             => 'Customer Invoice Date',
      'InvoiceNumber'           => 'Customer Invoice Number',
      'SupplierReferenceNumber' => 'Supplier Reference Number',
      'LotNumber'               => 'Tier Number',
      # Missing product codes
      'UnitType'                => 'Unit of Purchase',
      'UnitPrice'               => 'Price per Unit',
      'UnitQuantity'            => 'Quantity',
      'InvoiceValue'            => 'Total Cost (ex VAT)',
      'VATCharged'              => 'VAT Amount Charged',
      'Additional1'             => 'Matter Name',
      'Additional2'             => 'Pro-Bono Price per Unit',
      'Additional3'             => 'Pro-Bono Quantity',
      'Additional4'             => 'Pro-Bono Total Value',
      'Additional5'             => 'Sub-Contractor Name (If Applicable)',
      'Additional6'             => 'Pricing Mechanism',
      # Contract-specific values
      'ContractStartDate'       => 'Contract Start Date',
      'ContractEndDate'         => 'Contract End Date',
      'ContractValue'           => 'Expected Total Order Value',
      'ContractAwardChannel'    => 'Award Procedure',
    }.freeze

    BY_FRAMEWORK = {
      'RM3786' => LEGAL_FRAMEWORK,
      'RM3756' => LEGAL_FRAMEWORK,
      'RM3787' => LEGAL_FRAMEWORK,
    }.freeze

    def source_field_for(dest_field_name, framework_short_name)
      template_fields = BY_FRAMEWORK.fetch(framework_short_name)
      template_fields[dest_field_name]
    end
  end
end

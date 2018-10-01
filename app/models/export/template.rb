module Export
  ##
  # Included on SubmissionEntryRow to let us map per-template fields
  module Template
    # Mapping direction: destination_field in export => source_field from submission_entries.data
    module Legal
      COMMON = {
        'CustomerURN'             => 'Customer URN',
        'CustomerName'            => 'Customer Organisation Name',
        'CustomerPostCode'        => 'Customer Post Code',
        'InvoiceDate'             => 'Customer Invoice Date',
        'InvoiceNumber'           => 'Customer Invoice Number',
        'SupplierReferenceNumber' => 'Supplier Reference Number',
        'LotNumber'               => 'Tier Number',
      }.freeze

      INVOICE = {
        # Pricing
        'UnitType'                => 'Unit of Purchase',
        'UnitPrice'               => 'Price per Unit',
        'UnitQuantity'            => 'Quantity',
        'InvoiceValue'            => 'Total Cost (ex VAT)',
        'VATCharged'              => 'VAT Amount Charged',
        # Additional fields
        'Additional1'             => 'Matter Name',
        'Additional2'             => 'Pro-Bono Price per Unit',
        'Additional3'             => 'Pro-Bono Quantity',
        'Additional4'             => 'Pro-Bono Total Value',
        'Additional5'             => 'Sub-Contractor Name (If Applicable)',
        'Additional6'             => 'Pricing Mechanism',
      }.freeze

      ORDER = {
        'ContractStartDate'       => 'Contract Start Date',
        'ContractEndDate'         => 'Contract End Date',
        'ContractValue'           => 'Expected Total Order Value',
        'ContractAwardChannel'    => 'Award Procedure',
        'Additional1'             => 'Sub-Contractor Name',
        'Additional3'             => 'Call Off Managing Entity',
        'Additional4'             => 'Pro-bono work included? (Y/N)',
        'Additional5'             => 'Expected Pro-Bono value',
        'Additional6'             => 'Expression Of Interest Used (Y/N)',
        'Additional7'             => 'Customer Response Time',
      }.freeze

      MAPPINGS = {
        'invoice'  => INVOICE.merge(COMMON),
        'order'    => ORDER.merge(COMMON),
      }.freeze
    end

    BY_FRAMEWORK = {
      'RM3786' => Legal::MAPPINGS,
      'RM3756' => Legal::MAPPINGS,
      'RM3787' => Legal::MAPPINGS,
    }.freeze

    def source_field_for(dest_field_name, framework_short_name)
      template_fields = BY_FRAMEWORK.fetch(framework_short_name)
      template_fields.fetch(model.entry_type)[dest_field_name]
    end
  end
end

class Framework
  module Definition
    class RM1557viii < Base
      framework_short_name 'RM1557viii'
      framework_name 'G-Cloud 8'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('0.5'))

      LOT_1_SERVICES = [
        'CDN',
        'Compute',
        'Storage',
      ].freeze

      LOT_2_SERVICES = [
        'Application Deployment Platform'
      ].freeze

      LOT_3_SERVICES = [
        'Backup and Recovery',
        'Content Management',
        'CRM',
        'Dataset Visualisation',
        'Document / records',
        'Email',
        'ERP',
        'Forms',
        'Geographic Search',
        'Office Productivity',
        'Polls/Surveys',
        'Search',
        'Service Monitoring',
      ].freeze

      LOT_4_SERVICES = [
        'Business Analysis',
        'Deployment',
        'Design and Development',
        'Design Authority',
        'Project / Programme Management',
        'Project Specification and Selection',
        'Service Integration',
        'Service Management',
        'Strategy and Implementation Services',
        'Transition Management',
        'User Management',
      ].freeze

      MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_SERVICES,
          '2' => LOT_2_SERVICES,
          '3' => LOT_3_SERVICES,
          '4' => LOT_4_SERVICES,
        }
      }.freeze

      class Invoice < EntryData
        total_value_field 'Total Charge (Ex VAT)'

        field 'Buyer Cost Centre', :string
        field 'Call Off Contract Reference', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Buyer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Buyer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Buyer Contact Name', :string
        field 'Buyer Contact Number', :string
        field 'Buyer Email Address', :string
        field 'Invoice Date', :string, exports_to: 'CustomerInvoiceDate', ingested_date: true, presence: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Product / Service Group', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductCode', ingested_numericality: { only_integer: true }, presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, presence: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, presence: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, presence: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true, presence: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, presence: true
        field 'Expenses', :string, exports_to: 'Expenses', ingested_numericality: true, presence: true
      end

      class Order < EntryData
        total_value_field 'Call Off Value'

        field 'Call Off Contract Reference', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Buyer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Buyer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Buyer Contact Name', :string
        field 'Buyer Contact Number', :string
        field 'Buyer Email Address', :string
        field 'Buyer Call Off Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true, presence: true
        field 'Call Off End Date', :string, exports_to: 'ContractEndDate', ingested_date: true, presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Product / Service Group', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductCode', ingested_numericality: { only_integer: true }, presence: true
        field 'Call Off Value', :string, exports_to: 'ContractValue', ingested_numericality: true, presence: true
      end
    end
  end
end

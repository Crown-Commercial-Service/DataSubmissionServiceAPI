class Framework
  module Definition
    class RM1557vii < Base
      framework_short_name 'RM1557vii'
      framework_name 'G-Cloud 7'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('0.5'))

      LOT_1_SERVICES = [
        'CDN',
        'Compute',
        'Storage'
      ].freeze

      LOT_2_SERVICES = [
        'Application Deployment Platform',
        'Managed Component'
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
        'Service Analytics',
        'Service Monitoring',
        'User Alerts',
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
        total_value_field 'Total Charge (ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Order Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Contact Name', :string
        field 'Customer Contact Number', :string
        field 'Customer Email Address', :string
        field 'Customer Invoice Date', :string, exports_to: 'CustomerInvoiceDate', ingested_date: true, presence: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string
        field 'Product / Service Group 1', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductGroup', ingested_numericality: { only_integer: true }, presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, presence: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, presence: true
        field 'Total Charge (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true, presence: true
        field 'VAT Applicable', :string, exports_to: 'VATIncluded', presence: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, presence: true
        field 'Actual Delivery Date', :string, ingested_date: true
        field 'Expenses', :string, exports_to: 'Expenses', ingested_numericality: true, presence: true
        field 'Buyer Cost Centre', :string
        field 'Contract Number', :string
      end

      class Order < EntryData
        total_value_field 'Value'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Order Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Contact Name', :string
        field 'Customer Contact Number', :string
        field 'Customer Email Address', :string
        field 'Customer Order Number', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true, presence: true
        field 'Completion Date/Delivery Date', :string, exports_to: 'ContractEndDate', ingested_date: true, presence: true
        field 'Customer Order Date', :string, exports_to: 'CustomerOrderDate', ingested_date: true, presence: true
        field 'Product / Service Group 1', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductGroup', ingested_numericality: { only_integer: true }, presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Value', :string, exports_to: 'ContractValue', ingested_numericality: true, presence: true
        field 'Quantity', :string, exports_to: 'Quantity', ingested_numericality: true, presence: true
      end
    end
  end
end

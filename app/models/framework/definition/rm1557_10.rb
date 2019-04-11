class Framework
  module Definition
    class RM1557_10 < Base
      framework_short_name 'RM1557.10'
      framework_name 'G-Cloud 10'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('0.75'))

      UNIT_OF_MEASURE_VALUES = [
        'Per Unit',
        'Per User'
      ].freeze

      LOT_1_SERVICES = [
        'Archiving, Backup and Disaster Recovery',
        'Block Storage',
        'Compute and Application Hosting',
        'Container Service',
        'Content Delivery Network',
        'Data Warehousing',
        'Database',
        'Distributed Denial of Service Attack (DDOS) Protection',
        'Firewall',
        'Infrastructure and Platform Security',
        'Intrusion Detection',
        'Load Balancing',
        'Logging and Analysis',
        'Message Queuing and Processing',
        'Networking (including Network as a Service)',
        'NoSQL database',
        'Object Storage',
        'Platform as a Service (PaaS)',
        'Protective Monitoring',
        'Relational Database',
        'Search',
        'Storage'
      ].freeze

      LOT_2_SERVICES = [
        'Accounting and Finance',
        'Analytics and Business Intelligence',
        'Application Security',
        'Collaborative Working',
        'Creative, Design and Publishing',
        'Customer Relationship Management (CRM)',
        'Electronic Document and Records Management (EDRM)',
        'Healthcare',
        'Human Resources and Employee Management',
        'Information and Communication Technology (ICT)',
        'Legal and Enforcement',
        'Marketing',
        'Operations Management',
        'Project management and Planning',
        'Sales',
        'Schools, Education and Libraries',
        'Software Development Tools',
        'Transport and Logistics',
      ].freeze

      LOT_3_SERVICES = [
        'Ongoing Support',
        'Planning',
        'Setup and Migration',
        'Testing',
        'Training',
      ].freeze

      MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_SERVICES,
          '2' => LOT_2_SERVICES,
          '3' => LOT_3_SERVICES,
        }
      }.freeze

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Order Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer Unique Reference Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice/Credit Note Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice/Credit Note Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Service Group', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductCode', presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Measure', :string, exports_to: 'UnitType', case_insensitive_inclusion: { in: UNIT_OF_MEASURE_VALUES }
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true
        field 'Total Cost (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Amount Charged',  :string, exports_to: 'VATCharged', ingested_numericality: true
        field 'Expenses / Disbursements', :string, exports_to: 'Expenses', ingested_numericality: true
      end

      class Order < EntryData
        total_value_field 'Total Contract Value'

        field 'Order Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer Unique Reference Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Service Group', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductCode', presence: true
        field 'Total Contract Value', :string, exports_to: 'ContractValue', ingested_numericality: true
      end
    end
  end
end

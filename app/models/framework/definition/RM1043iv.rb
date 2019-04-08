class Framework
  module Definition
    class RM1043iv < Base
      framework_short_name 'RM1043iv'
      framework_name 'Digital Outcomes & Specialists 2'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('1'))

      UNIT_OF_MEASURE_VALUES = [
        'Day',
      ].freeze

      LOT_1_SERVICES = [
        'User Experience and Design',
        'Performance Analysis and Data',
        'Security',
        'Service Delivery',
        'Software Development',
        'Support and Operations',
        'Testing and Auditing',
        'User Research',
      ].freeze

      LOT_2_SERVICES = [
        'Agile Coach',
        'Business Analyst',
        'Communications Manager',
        'Content Designer or Copywriter',
        'Cyber Security Consultant',
        'Data Architect',
        'Data Engineer',
        'Data Scientist',
        'Delivery Manager or Project Manager',
        'Designer',
        'Developer',
        'Performance Analyst',
        'Portfolio Manager',
        'Product Manager',
        'Programme Delivery Manager',
        'Quality Assurance Analyst',
        'Service Manager',
        'Technical Architect',
        'User Researcher',
        'Web Operations Engineer',
      ].freeze

      LOT_3_SERVICES = [
        'User research studios',
      ].freeze

      LOT_4_SERVICES = [
        'User research participants'
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

        field 'SoW / Order Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Buyer Cost Centre', :string
        field 'Contract Reference', :string, presence: true
        field 'Buyer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Buyer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Buyer Contact Name', :string
        field 'Buyer Contact Number', :string
        field 'Buyer Email Address', :string
        field 'Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true, presence: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Project Phase', :string, exports_to: 'Additional1', presence: true
        field 'Project Name', :string, exports_to: 'Additional2', presence: true
        field 'Service provided', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Location', :string, exports_to: 'Additional3', presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', case_insensitive_inclusion: { in: UNIT_OF_MEASURE_VALUES }
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, presence: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, presence: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true, presence: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, presence: true
        field 'Actual Delivery Date SoW complete', :string
      end

      class Order < EntryData
        total_value_field 'Total Value'

        field 'SoW / Order Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'SoW / Order Date', :string, exports_to: 'CustOrderDate', ingested_date: true, presence: true
        field 'Contract Reference', :string, exports_to: 'CustomerReferenceNumber'
        field 'Buyer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Buyer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Buyer Contact Name', :string
        field 'Buyer Contact Number', :string
        field 'Buyer Email Address', :string
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true, presence: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true, presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Project Name', :string, exports_to: 'Additional5', presence: true
        field 'Project Phase', :string, exports_to: 'Additional4', presence: true
        field 'Service provided', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Location', :string, exports_to: 'Additional6', presence: true
        field 'Day Rate', :string, exports_to: 'Additional7', ingested_numericality: true, presence: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, presence: true
        field 'Total Value', :string, exports_to: 'ContractValue', ingested_numericality: true, presence: true
      end
    end
  end
end

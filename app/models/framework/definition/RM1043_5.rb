class Framework
  module Definition
    class RM1043_5 < Base
      framework_short_name 'RM1043.5'
      framework_name 'Digital Outcomes and Specialists 3'

      management_charge_rate BigDecimal('1')

      UNIT_OF_MEASURE_VALUES = [
        'Day',
        'Each'
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
        'User Research Studios',
      ].freeze

      LOT_4_SERVICES = [
        'User Research Participants'
      ].freeze

      SERVICE_PROVIDED_VALUES = (
        LOT_1_SERVICES +
        LOT_2_SERVICES +
        LOT_3_SERVICES +
        LOT_4_SERVICES
      ).freeze

      MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_SERVICES,
          '2' => LOT_2_SERVICES,
          '3' => LOT_3_SERVICES,
          '4' => LOT_4_SERVICES,
        }
      }.freeze

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Opportunity ID', :string, exports_to: 'SupplierReferenceNumber', presence: true, length: { minimum: 4 }, ingested_numericality: { only_integer: true }
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Unique Reference Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice/Credit Note Date', :string, exports_to: 'Invoice Date', ingested_date: true, presence: true
        field 'Customer Invoice/Credit Note Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Service Provided', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }, case_insensitive_inclusion: { in: SERVICE_PROVIDED_VALUES }
        field 'Unit of Measure', :string, exports_to: 'UnitType', case_insensitive_inclusion: { in: UNIT_OF_MEASURE_VALUES }
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, presence: true
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, presence: true
        field 'Total Cost (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true, presence: true
      end

      class Order < EntryData
        total_value_field 'Total Contract Value'

        field 'Opportunity ID', :string, exports_to: 'SupplierReferenceNumber', presence: true, length: { minimum: 4 }, ingested_numericality: { only_integer: true }
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Unique Reference Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true, presence: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true, presence: true
        field 'Total Contract Value', :string, exports_to: 'ContractValue', ingested_numericality: true, presence: true
      end
    end
  end
end

class Framework
  module Definition
    class RM3797 < Base
      framework_short_name 'RM3797'
      framework_name       'Journal Subscriptions'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('1'))

      PRODUCT_GROUPS = [
        'Print Journal',
        'Electronic Journal',
        'Print and Electronic Journal'
      ].freeze

      UNIT_OF_MEASURE_VALUES = [
        'Each'
      ].freeze

      UNSPSC_CODES = [
        '86141704'
      ].freeze

      class Invoice < EntryData
        total_value_field 'Total Charge (Ex VAT)'

        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Product Group', :string, exports_to: 'ProductGroup', case_insensitive_inclusion: { in: PRODUCT_GROUPS }
        field 'Publisher Name', :string, exports_to: 'ProductClass'
        field 'Product Description', :string, exports_to: 'ProductDescription'
        field 'Crown Commercial Service Unique Product Codes', :string, exports_to: 'ProductCode'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, case_insensitive_inclusion: { in: UNSPSC_CODES }
        field 'Unit of Measure', :string, exports_to: 'UnitType', case_insensitive_inclusion: { in: UNIT_OF_MEASURE_VALUES }
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Publisher List Price', :string, exports_to: 'Additional2', ingested_numericality: true, allow_nil: true
      end
    end
  end
end

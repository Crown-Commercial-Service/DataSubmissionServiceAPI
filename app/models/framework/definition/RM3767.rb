class Framework
  module Definition
    class RM3767 < Base
      framework_short_name 'RM3767'
      framework_name       'Supply and Fit of Tyres (RM3767)'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('1'))

      PRODUCT_TYPES = [
        'Tyre - Supply ONLY',
        'Tyre - Supply + Fit',
        'Casing Credit'
      ].freeze

      VEHICLE_CATEGORY = [
        'Car',
        '4x4',
        'Van',
        'Truck',
        'Motorcycle',
        'Agrarian'
      ].freeze

      TYRE_GRADE = [
        'Premium',
        'Mid-Range',
        'Budget'
      ].freeze

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Product Type', :string, exports_to: 'ProductGroup', case_insensitive_inclusion: { in: PRODUCT_TYPES }
        field 'Tyre Brand', :string, exports_to: 'ProductClass', presence: true
        field 'Tyre Width', :string, presence: true
        field 'Aspect Ratio', :string, presence: true
        field 'Rim Diameter', :string, presence: true
        field 'Load Capacity', :string
        field 'Speed Index', :string
        field 'Vehicle Category', :string, exports_to: 'ProductSubClass', case_insensitive_inclusion: { in: VEHICLE_CATEGORY }
        field 'Tyre Grade', :string, exports_to: 'Additional1', case_insensitive_inclusion: { in: TYRE_GRADE }
        field 'Associated Service', :string, exports_to: 'ProductDescription', presence: true
        field 'Run Flats (Y/N)', :string, exports_to: 'Additional2', presence: true, case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true
        field 'Total Cost (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Amount Charged', :string, exports_to: 'VATCharged', ingested_numericality: true
        field 'Subcontractor Name', :string, exports_to: 'Additional8'
      end
    end
  end
end

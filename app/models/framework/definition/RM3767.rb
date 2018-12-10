class Framework
  module Definition
    class RM3767 < Base
      framework_short_name 'RM3767'
      framework_name       'Supply and Fit of Tyres (RM3767)'

      management_charge_rate BigDecimal('1')

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, inclusion: { in: %w[1 2] }
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        # field 'Tyre Specification', :string, exports_to: 'ProductCode', presence: true
        field 'Vehicle Category', :string, exports_to: 'ProductSubClass'
        field 'Associated Service', :string, exports_to: 'ProductDescription'
        field 'Tyre Width', :string
        field 'Aspect Ratio', :string
        field 'Rim Diameter', :string
        field 'Load Capacity', :string
        field 'Speed Index', :string
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Customer Invoice Line Number', :string
        field 'Product Type', :string, exports_to: 'ProductGroup'
        field 'Tyre Brand', :string, exports_to: 'ProductClass'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Total Cost (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'VAT Amount Charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Tyre Grade', :string, exports_to: 'Additional1'
        field 'Run Flats (Y/N)', :string, exports_to: 'Additional2', presence: true, case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        # field 'Core Tyre Price', :string, exports_to: 'Additional3', ingested_numericality: true
        # field 'Valve Cost', :string, exports_to: 'Additional4', ingested_numericality: true
        # field 'Fitment Cost', :string, exports_to: 'Additional5', ingested_numericality: true
        # field 'Balance Cost', :string, exports_to: 'Additional6', ingested_numericality: true
        # field 'Disposal Cost', :string, exports_to: 'Additional7', ingested_numericality: true
        field 'Subcontractor Name', :string, exports_to: 'Additional8'
      end
    end
  end
end

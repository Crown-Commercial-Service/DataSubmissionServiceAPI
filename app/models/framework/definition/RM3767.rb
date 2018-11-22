class Framework
  module Definition
    class RM3767 < Base
      framework_short_name 'RM3767'
      framework_name       'Supply and Fit of Tyres (RM3767)'

      management_charge_rate BigDecimal('1')

      class Invoice < Sheet
        total_value_field 'Total Cost (ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
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
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true, allow_nil: true
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true, allow_nil: true
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged', numericality: true, allow_nil: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Tyre Grade', :string, exports_to: 'Additional1'
        field 'Run Flats (Y/N)', :string, exports_to: 'Additional2', presence: true, inclusion: { in: %w[Y N y n] }
        # field 'Core Tyre Price', :decimal, exports_to: 'Additional3', numericality: true
        # field 'Valve Cost', :decimal, exports_to: 'Additional4', numericality: true
        # field 'Fitment Cost', :decimal, exports_to: 'Additional5', numericality: true
        # field 'Balance Cost', :decimal, exports_to: 'Additional6', numericality: true
        # field 'Disposal Cost', :decimal, exports_to: 'Additional7', numericality: true
        field 'Subcontractor Name', :string, exports_to: 'Additional8'
      end
    end
  end
end

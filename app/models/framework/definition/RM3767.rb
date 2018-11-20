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
        field 'Tyre Specification', :string, exports_to: 'ProductCode', presence: true
        field 'Vehicle Category', :string, exports_to: 'ProductSubClass', presence: true
        field 'Associated Service', :string, exports_to: 'ProductDescription', presence: true
        field 'Tyre Width', :decimal, numericality: true
        field 'Aspect Ratio', :integer, numericality: { only_integer: true }
        field 'Rim Diameter', :decimal, numericality: true
        field 'Load Capacity', :integer, numericality: { only_integer: true }
        field 'Speed Index', :string, presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string, presence: true
        field 'Product Type', :string, exports_to: 'ProductGroup', presence: true
        field 'Tyre Brand', :string, exports_to: 'ProductClass', presence: true
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Cost Centre', :string, presence: true
        field 'Contract Number', :string, presence: true
        field 'Tyre Grade', :string, exports_to: 'Additional1', presence: true
        field 'Run Flats (Y/N)', :string, exports_to: 'Additional2', presence: true
        field 'Core Tyre Price', :decimal, exports_to: 'Additional3', numericality: true
        field 'Valve Cost', :decimal, exports_to: 'Additional4', numericality: true
        field 'Fitment Cost', :decimal, exports_to: 'Additional5', numericality: true
        field 'Balance Cost', :decimal, exports_to: 'Additional6', numericality: true
        field 'Disposal Cost', :decimal, exports_to: 'Additional7', numericality: true
        field 'Subcontractor Name', :string, exports_to: 'Additional8', presence: true
      end
    end
  end
end

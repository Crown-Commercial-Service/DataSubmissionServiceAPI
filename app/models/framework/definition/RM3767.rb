class Framework
  module Definition
    class RM3767 < Base
      framework_short_name 'RM3767'
      framework_name       'Supply and Fit of Tyres (RM3767)'

      management_charge_rate BigDecimal('1')

      class Invoice < Sheet
        total_value_field 'Total Cost (Ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Tyre Specification ', :string, exports_to: 'ProductCode'
        field 'Vehicle Category', :string, exports_to: 'ProductSubClass'
        field 'Associated Service', :string, exports_to: 'ProductDescription'
        field 'Tyre Width', :decimal
        field 'Aspect Ratio', :integer
        field 'Rim Diameter', :decimal
        field 'Load Capacity', :integer
        field 'Speed Index', :string
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Customer Invoice Line Number', :string
        field 'Product Type', :string, exports_to: 'ProductGroup'
        field 'Tyre Brand', :string, exports_to: 'ProductClass'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice'
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue'
        field 'Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Tyre Grade', :string, exports_to: 'Additional1'
        field 'Run Flats (Y/N)', :string, exports_to: 'Additional2'
        field 'Core Tyre Price', :decimal, exports_to: 'Additional3'
        field 'Valve Cost', :decimal, exports_to: 'Additional4'
        field 'Fitment Cost', :decimal, exports_to: 'Additional5'
        field 'Balance Cost', :decimal, exports_to: 'Additional6'
        field 'Disposal Cost', :decimal, exports_to: 'Additional7'
        field 'Subcontractor Name', :string, exports_to: 'Additional8'
      end
    end
  end
end

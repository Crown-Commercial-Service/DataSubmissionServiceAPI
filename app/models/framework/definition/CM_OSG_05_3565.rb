class Framework
  module Definition
    class CM_OSG_05_3565 < Base
      framework_short_name 'CM/OSG/05/3565'
      framework_name       'Laundry Services - Wave 2'

      class Invoice < Sheet
        total_value_field 'Total Spend'

        field 'Customer Postcode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Service Type', :string, exports_to: 'ProductGroup'
        field 'Product Group', :string, exports_to: 'ProductClass'
        field 'Product Classification', :string, exports_to: 'ProductSubClass'
        field 'Item Name or WAPP', :string, exports_to: 'ProductDescription'
        field 'Item Code', :string, exports_to: 'ProductCode'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Item', :decimal, exports_to: 'UnitPrice'
        field 'VAT Included', :boolean, exports_to: 'VATIncluded'
        field 'Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Total Spend', :decimal, exports_to: 'InvoiceValue'
        field 'Manufacturers Product Code', :string, exports_to: 'Additional1'
        field 'Unit Quantity', :string, exports_to: 'Additional2'
        field 'Cost Centre', :string
        field 'Contract Number', :string
      end
    end
  end
end

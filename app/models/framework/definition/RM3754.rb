class Framework
  module Definition
    class RM3754 < Base
      framework_short_name 'RM3754'
      framework_name       'Vehicle Telematics'

      class Invoice < Sheet
        total_value_field 'Total Charge (ex VAT)'

        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Product Description', :string, exports_to: 'ProductDescription'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice'
        field 'Total Number of Units', :decimal, exports_to: 'UnitQuantity'
        field 'Total Charge (ex VAT)', :decimal, exports_to: 'InvoiceValue'
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Vehicle Registration No', :string, exports_to: 'Additional1'
        field 'Payment Profile', :string, exports_to: 'Additional2'
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional3'
      end
    end
  end
end

class Framework
  module Definition
    class RM3772 < Base
      framework_short_name 'RM3772'
      framework_name       'Specialist Laundry Services (for Surgical Gowns, D'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Charge (Ex VAT)'

        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Category', :string, exports_to: 'ProductClass'
        field 'Item', :string, exports_to: 'ProductDescription'
        field 'Item Code', :string, exports_to: 'ProductCode'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitCost'
        field 'Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Service Type', :string, exports_to: 'ProductGroup'
        field 'Total Charge (Ex VAT)', :decimal, exports_to: 'InvoiceValue'
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged'
        field 'Cost Centre ', :string
        field 'Contract Number', :string
        field 'Baseline Price', :decimal, exports_to: 'Additional1'
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2'
      end

      class Order < Sheet
        total_value_field 'Customer Order/Contract Value'

        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Number of items', :decimal
        field 'Customer Order/Contract Value', :decimal, exports_to: 'ContractValue'
        field 'Project Name', :string, exports_to: 'ProductDescription'
      end
    end
  end
end

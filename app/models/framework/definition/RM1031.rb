class Framework
  module Definition
    class RM1031 < Base
      framework_short_name 'RM1031'
      framework_name       'Laundry and Linen Services (RM1031)'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Charge (Ex VAT)'

        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true
        field 'Category', :string, exports_to: 'ProductClass', presence: true
        field 'Item Code', :string, exports_to: 'ProductCode'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Charge (Ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Cost Centre', :string, presence: true
        field 'Contract Number', :string, presence: true
        field 'Baseline Price', :decimal, exports_to: 'Additional1', numericality: true
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2', presence: true
        field 'Item', :string, exports_to: 'ProductDescription', presence: true
      end

      class Order < Sheet
        total_value_field 'Customer Order/Contract Value'

        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Number of items', :decimal
        field 'Customer Order/Contract Value', :decimal, exports_to: 'ContractValue'
        field 'Project Name', :string, exports_to: 'ProductDescription'
      end
    end
  end
end

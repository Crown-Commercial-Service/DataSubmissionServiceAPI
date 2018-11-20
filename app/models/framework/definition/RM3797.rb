class Framework
  module Definition
    class RM3797 < Base
      framework_short_name 'RM3797'
      framework_name       'Journal Subscriptions'

      management_charge_rate BigDecimal('1')

      class Invoice < Sheet
        total_value_field 'Total Charge (Ex VAT)'

        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Product Group', :string, exports_to: 'ProductGroup', presence: true
        field 'Publisher Name', :string, exports_to: 'ProductClass', presence: true
        field 'Product Description', :string, exports_to: 'ProductDescription', presence: true
        field 'Crown Commercial Service Unique Product Codes', :string, exports_to: 'ProductCode', presence: true
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Measure', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Charge (Ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Cost Centre', :string, presence: true
        field 'Contract Number', :string, presence: true
        field 'Publisher List Price', :decimal, exports_to: 'Additional2', numericality: true
      end
    end
  end
end

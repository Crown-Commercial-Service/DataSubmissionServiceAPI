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
        field 'Service Type', :string, exports_to: 'ProductGroup'
        field 'Category', :string, exports_to: 'ProductClass'
        field 'Item Code', :string, exports_to: 'ProductCode'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Baseline Price', :string, exports_to: 'Additional1', ingested_numericality: true, allow_nil: true
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2'
        field 'Item', :string, exports_to: 'ProductDescription'
      end

      class Order < Sheet
        total_value_field 'Customer Order/Contract Value'

        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Number of items', :string, ingested_numericality: true, allow_nil: true
        field 'Customer Order/Contract Value', :string, exports_to: 'ContractValue', ingested_numericality: true, allow_nil: true
        field 'Project Name', :string, exports_to: 'ProductDescription'
      end
    end
  end
end

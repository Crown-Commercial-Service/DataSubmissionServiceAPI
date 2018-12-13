class Framework
  module Definition
    class RM3772 < Base
      framework_short_name 'RM3772'
      framework_name       'Specialist Laundry Services (for Surgical Gowns, D'

      management_charge_rate BigDecimal('0.5')

      class Invoice < EntryData
        total_value_field 'Total Charge (Ex VAT)'

        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Category', :string, exports_to: 'ProductClass'
        field 'Item', :string, exports_to: 'ProductDescription'
        field 'Item Code', :string, exports_to: 'ProductCode'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitCost', ingested_numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Baseline Price', :string, exports_to: 'Additional1', ingested_numericality: true
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2'
      end

      class Order < EntryData
        total_value_field 'Customer Order/Contract Value'

        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Number of items', :string
        field 'Customer Order/Contract Value', :string, exports_to: 'ContractValue'
        field 'Project Name', :string, exports_to: 'ProductDescription'
      end
    end
  end
end

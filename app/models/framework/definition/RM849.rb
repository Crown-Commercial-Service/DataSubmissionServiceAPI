class Framework
  module Definition
    class RM849 < Base
      framework_short_name 'RM849'
      framework_name       'Laundry & Linen Services Framework'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Invoice Line Total Value ex VAT and Expenses'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
        field 'Supplier Order Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Order Number', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string, exports_to: 'Additional1'
        field 'Invoice Line Product / Service Description', :string, exports_to: 'ProductDescription'
        field 'Invoice Line Service Grouping', :string, exports_to: 'ProductGroup', presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC'
        field 'Product Code', :string, exports_to: 'ProductCode', presence: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Invoice Line Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Invoice Line Total Value ex VAT and Expenses', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT Applicable', :boolean, exports_to: 'VATIncluded', presence: true, inclusion: { in: %w[true false] }
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Contract Number', :string
        field 'Cost Centre', :string
      end

      class Order < Sheet
        total_value_field 'Customer Order/Contract Value'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Order Number', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Order Date', :date
        field 'Customer Contract Start Date', :date, exports_to: 'ContractStartDate'
        field 'Customer Contract End Date', :date, exports_to: 'ContractEndDate'
        field 'Project Name', :string, exports_to: 'ProductDescription'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Number of items', :integer
        field 'Customer Order/Contract Value', :decimal, exports_to: 'ContractValue'
        field 'Invoice Line Service Grouping', :string, exports_to: 'ContractAwardChannel', presence: true
        field 'Invoice Line Product / Service Description', :string, exports_to: 'Additional1'
      end
    end
  end
end

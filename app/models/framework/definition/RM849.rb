class Framework
  module Definition
    class RM849 < Base
      framework_short_name 'RM849'
      framework_name       'Laundry & Linen Services Framework'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('0.5'))

      class Invoice < EntryData
        total_value_field 'Invoice Line Total Value ex VAT and Expenses'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Order Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Order Number', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string, exports_to: 'Additional1'
        field 'Invoice Line Product / Service Description', :string, exports_to: 'ProductDescription'
        field 'Invoice Line Service Grouping', :string, exports_to: 'ProductGroup'
        field 'UNSPSC', :string, exports_to: 'UNSPSC'
        field 'Product Code', :string, exports_to: 'ProductCode'
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true
        field 'Invoice Line Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Invoice Line Total Value ex VAT and Expenses', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Applicable', :string, exports_to: 'VATIncluded', presence: true, case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Contract Number', :string
        field 'Cost Centre', :string
      end

      class Order < EntryData
        total_value_field 'Customer Order/Contract Value'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Order Number', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Order Date', :string
        field 'Customer Contract Start Date', :string, exports_to: 'ContractStartDate'
        field 'Customer Contract End Date', :string, exports_to: 'ContractEndDate'
        field 'Project Name', :string, exports_to: 'ProductDescription'
        field 'UNSPSC', :string, exports_to: 'UNSPSC'
        field 'Number of items', :string
        field 'Customer Order/Contract Value', :string, exports_to: 'ContractValue', ingested_numericality: true
        field 'Invoice Line Service Grouping', :string, exports_to: 'ContractAwardChannel', presence: true
        field 'Invoice Line Product / Service Description', :string, exports_to: 'Additional1'
      end
    end
  end
end

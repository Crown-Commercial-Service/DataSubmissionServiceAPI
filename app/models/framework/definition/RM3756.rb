class Framework
  module Definition
    class RM3756 < Base
      framework_short_name 'RM3756'
      framework_name       'Rail Legal Services'

      management_charge_rate BigDecimal('1.5')

      class Invoice < Sheet
        total_value_field 'Total Cost (ex VAT)'

        field 'Tier Number', :string, exports_to: 'LotNumber'
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName'
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Service Type', :string, exports_to: 'ProductGroup'
        field 'Primary Specialism', :string, exports_to: 'ProductDescription'
        field 'Practitioner Grade', :string, exports_to: 'ProductSubClass'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice'
        field 'Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue'
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber'
        field 'Pricing Mechanism', :string, exports_to: 'Additional5'
        field 'Award Procedure', :string, exports_to: 'Additional6'
        field 'Pro-Bono Price per Unit', :decimal, exports_to: 'Additional1'
        field 'Pro-Bono Quantity', :decimal, exports_to: 'Additional2'
        field 'Pro-Bono Total Value', :decimal, exports_to: 'Additional3'
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4'
      end

      class Order < Sheet
        total_value_field 'Expected Total Order Value'

        field 'Tier Number', :string, exports_to: 'LotNumber'
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName'
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode'
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber'
        field 'Matter Description', :string, exports_to: 'ProductDescription'
        field 'Contract Start Date', :date, exports_to: 'ContractStartDate'
        field 'Contract End Date', :date, exports_to: 'ContractEndDate'
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel'
        field 'Expected Total Order Value', :decimal, exports_to: 'ContractValue'
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1'
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2'
        field 'Customer Response Time', :string, exports_to: 'Additional6'
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3'
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4'
        field 'Expected Pro-Bono value', :decimal, exports_to: 'Additional5'
      end
    end
  end
end

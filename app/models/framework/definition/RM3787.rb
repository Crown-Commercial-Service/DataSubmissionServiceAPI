class Framework
  module Definition
    class RM3787 < Base
      framework_short_name 'RM3787'
      framework_name       'Finance & Complex Legal Services'

      class Invoice < Sheet
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName'
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode'
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Service Type', :string, exports_to: 'ProductGroup'
        field 'Primary Specialism', :string, exports_to: 'ProductClass'
        field 'Practitioner Grade', :string, exports_to: 'ProductDescription'
        field 'Pricing Mechanism', :string, exports_to: 'ProductSubClass'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice'
        field 'Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceTotal'
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged'
        field 'Pro-Bono Price per Unit', :decimal, exports_to: 'Additional1'
        field 'Pro-Bono Quantity', :decimal, exports_to: 'Additional2'
        field 'Pro-Bono Total Value', :decimal, exports_to: 'Additional3'
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4'
      end

      class Order < Sheet
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName'
        field 'Customer Post Code', :string, exports_to: 'CustomerPostcode'
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber'
        field 'Matter Description', :string, exports_to: 'ProductDescription'
        field 'Contract Start Date', :date, exports_to: 'ContractStartDate'
        field 'Contract End Date', :date, exports_to: 'ContractEndDate'
        field 'Expected Total Order Value', :decimal, exports_to: 'ContractValue'
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1'
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2'
        field 'Customer Response Time', :string, exports_to: 'Additional6'
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3'
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel'
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4'
        field 'Expected Pro-Bono value', :decimal, exports_to: 'Additional5'
      end
    end
  end
end

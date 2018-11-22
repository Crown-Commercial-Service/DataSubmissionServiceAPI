class Framework
  module Definition
    class RM3787 < Base
      framework_short_name 'RM3787'
      framework_name       'Finance & Complex Legal Services'

      management_charge_rate BigDecimal('1.5')

      class Invoice < Sheet
        total_value_field 'Total Cost (ex VAT)'

        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true
        field 'Primary Specialism', :string, exports_to: 'ProductClass', presence: true
        field 'Practitioner Grade', :string, exports_to: 'ProductDescription', presence: true
        field 'Pricing Mechanism', :string, exports_to: 'ProductSubClass', presence: true
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Pro-Bono Price per Unit', :decimal, exports_to: 'Additional1', numericality: true
        field 'Pro-Bono Quantity', :decimal, exports_to: 'Additional2', numericality: true
        field 'Pro-Bono Total Value', :decimal, exports_to: 'Additional3', numericality: true
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4', presence: true
      end

      class Order < Sheet
        total_value_field 'Expected Total Order Value'

        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostcode', presence: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Matter Description', :string, exports_to: 'ProductDescription', presence: true
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true
        field 'Expected Total Order Value', :decimal, exports_to: 'ContractValue', numericality: true
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1', presence: true
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2', presence: true
        field 'Customer Response Time', :string, exports_to: 'Additional6', presence: true
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3', presence: true
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel', presence: true
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4', presence: true
        field 'Expected Pro-Bono value', :decimal, exports_to: 'Additional5', presence: true
      end
    end
  end
end

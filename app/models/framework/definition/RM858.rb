class Framework
  module Definition
    class RM858 < Base
      framework_short_name 'RM858'
      framework_name       'Pan Govt Vehicle Leasing & Fleet Outsource Solutio'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Invoice Line Total Value ex VAT'

        field 'Lot Number', :string, exports_to: 'LotNumber'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Customer Invoice Line Number', :string
        field 'Invoice Line Product / Service Description', :string, exports_to: 'ProductDescription'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit ex VAT', :decimal, exports_to: 'UnitPrice'
        field 'Invoice Line Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Invoice Line Total Value ex VAT', :decimal, exports_to: 'InvoiceValue'
        field 'VAT Applicable', :boolean, exports_to: 'VATIncluded'
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged'
        field 'Spend Code', :string, exports_to: 'PromotionCode'
        field 'Invoice Line Product / Service Grouping', :string, exports_to: 'ProductGroup'
        field 'CAP Code', :string, exports_to: 'ProductCode'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass'
        field 'Vehicle Derivative', :string, exports_to: 'Additional1'
        field 'Product Classification', :string, exports_to: 'Additional2'
        field 'Vehicle Registration', :string, exports_to: 'Additional3'
        field 'Vehicle Convertors Name', :string, exports_to: 'Additional4'
        field 'Vehicle Conversion Type', :string, exports_to: 'Additional5'
        field 'Vehicle Type', :string, exports_to: 'Additional6'
        field 'Fuel Type', :string, exports_to: 'Additional7'
        field 'CO2 Emission Levels', :string, exports_to: 'Additional8'
        field 'Lease Period', :string
        field 'Lease Start Date', :date
        field 'Lease End Date', :date
        field 'Payment Profile', :string
        field 'Annual Lease Mileage', :decimal
        field 'Base Vehicle Price ex VAT', :decimal
        field 'Lease Cost excluding Optional Extras and Conversion ex VAT', :decimal
        field 'Lease Finance Charge ex VAT', :decimal
        field 'Lease Finance Margin ex VAT', :decimal
        field 'Vehicle Purchase Terms', :string
        field 'Standard Vehicle Discount (%)', :decimal
        field 'Enhanced Vehicle Discount (%)', :decimal
        field 'Annual Service Maintenance & Repair Costs ex VAT', :decimal
        field 'Annual Breakdown & Recovery Costs ex VAT', :decimal
        field 'Residual Value', :decimal
        field 'Cost Centre', :string
        field 'Contract Number', :string
      end
    end
  end
end

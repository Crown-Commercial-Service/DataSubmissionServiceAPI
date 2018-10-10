class Framework
  module Definition
    class RM3710 < Base
      framework_short_name 'RM3710'
      framework_name       'Vehicle Lease and Fleet Management'

      class Invoice < Sheet
        total_value_field 'Total Charge (Ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit (Ex VAT)', :decimal, exports_to: 'UnitPrice'
        field 'Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Total Charge (Ex VAT)', :decimal, exports_to: 'InvoiceValue'
        field 'VAT Applicable', :string, exports_to: 'VATIncluded'
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged'
        field 'CAP Code', :string, exports_to: 'ProductCode'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass'
        field 'Product Description - Vehicle Derivative / Fleet Management Services', :string, exports_to: 'ProductDescription'
        field 'Product Classification', :string, exports_to: 'ProductGroup'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2'
        field 'Vehicle Registration', :string, exports_to: 'Additional1'
        field 'Fuel Type', :string, exports_to: 'Additional4'
        field 'CO2 Emission Levels', :decimal, exports_to: 'Additional3'
        field 'Vehicle Convertors Name', :string, exports_to: 'Additional5'
        field 'Vehicle Conversion Type', :string, exports_to: 'Additional6'
        field 'Vehicle Type', :string, exports_to: 'Additional7'
        field 'Lease Start Date', :date, exports_to: 'Additional8'
        field 'Lease End Date', :date
        field 'Lease Period (Months)', :integer
        field 'Payment Profile', :string
        field 'Annual Lease Mileage', :decimal
        field 'Base Vehicle Price ex VAT', :decimal
        field 'Lease Finance Charge ex VAT', :decimal
        field 'Annual Service Maintenance & Repair Costs ex VAT', :decimal
        field 'Residual Value', :decimal
        field 'Total Manufacturer Discount (%)', :decimal
        field 'Spend Code', :string, exports_to: 'PromotionCode'
      end
    end
  end
end

class Framework
  module Definition
    class RM1070 < Base
      framework_short_name 'RM1070'
      framework_name       'Vehicle Purchase (RM1070)'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Invoice Line Number', :string, presence: true
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass', presence: true
        field 'Vehicle Make', :string, exports_to: 'ProductClass', presence: true
        field 'Vehicle Segment', :string, exports_to: 'ProductGroup', presence: true
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Invoice Price Per Vehicle', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :integer, exports_to: 'UnitQuantity', numericality: { only_integer: true }
        field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'Additional Expenditure to provide goods', :decimal, exports_to: 'Expenses', numericality: true
        field 'VAT Applicable?', :boolean, exports_to: 'VATIncluded', presence: true, inclusion: { in: %w[true false] }
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Vehicle CAP Code', :string, exports_to: 'ProductCode', presence: true
        field 'Vehicle Trim/Derivative', :string, exports_to: 'ProductDescription', presence: true
        field 'Cost Centre', :string, presence: true
        field 'Contract Number', :string, presence: true
        field 'Vehicle Registration Number', :string, exports_to: 'Additional1', presence: true
        field 'All Conversion and third party conversion costs excluding factory fit options', :decimal, exports_to: 'Additional2', numericality: true
        field 'CO2 Emissions', :decimal, exports_to: 'Additional3', numericality: true
        field 'Fuel Type', :string, exports_to: 'Additional4', presence: true
        field 'Customer Support Terms', :decimal, exports_to: 'Additional5', numericality: true
        field 'Leasing Company', :string, exports_to: 'Additional6', presence: true
        field 'Additional support terms given to Lease companies', :decimal, exports_to: 'Additional7', numericality: true
        field 'Invoice Price Excluding Options', :decimal, exports_to: 'Additional8', numericality: true
        field 'List Price Excluding Options', :decimal, numericality: true
        field 'eAuction Contract No', :string, presence: true
      end
    end
  end
end

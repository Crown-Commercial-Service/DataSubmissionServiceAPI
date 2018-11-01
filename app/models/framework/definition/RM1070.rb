class Framework
  module Definition
    class RM1070 < Base
      framework_short_name 'RM1070'
      framework_name       'Vehicle Purchase (RM1070)'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, inclusion: { in: %w[1 2 3 4 5 6 7 8 9] }
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :string, exports_to: 'CustomerURN', presence: true, urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', presence: true, ingested_date: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Invoice Line Number', :string
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Segment', :string, exports_to: 'ProductGroup'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Invoice Price Per Vehicle', :decimal, exports_to: 'UnitPrice', numericality: true, allow_nil: true
        field 'Quantity', :integer, exports_to: 'UnitQuantity'
        field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT', :decimal, exports_to: 'InvoiceValue', presence: true, numericality: true
        field 'Additional Expenditure to provide goods', :decimal, exports_to: 'Expenses', numericality: true, allow_nil: true
        field 'VAT Applicable?', :string, exports_to: 'VATIncluded', inclusion: { in: ['Y', 'N'], message: "Is VAT applicable on this product or service? Enter 'Y' or 'N'" }
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true, allow_nil: true
        field 'Vehicle CAP Code', :string, exports_to: 'ProductCode'
        field 'Vehicle Trim/Derivative', :string, exports_to: 'ProductDescription'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Vehicle Registration Number', :string, exports_to: 'Additional1'
        field 'All Conversion and third party conversion costs excluding factory fit options', :decimal, exports_to: 'Additional2', numericality: true, allow_nil: true
        field 'CO2 Emissions', :decimal, exports_to: 'Additional3', numericality: true, allow_nil: true
        field 'Fuel Type', :string, exports_to: 'Additional4'
        field 'Customer Support Terms', :decimal, exports_to: 'Additional5', numericality: true, allow_nil: true
        field 'Leasing Company', :string, exports_to: 'Additional6'
        field 'Additional support terms given to Lease companies', :decimal, exports_to: 'Additional7', numericality: true, allow_nil: true
        field 'Invoice Price Excluding Options', :decimal, exports_to: 'Additional8', numericality: true, allow_nil: true
        field 'List Price Excluding Options', :decimal, numericality: true, allow_nil: true
        field 'eAuction Contract No', :string
      end
    end
  end
end

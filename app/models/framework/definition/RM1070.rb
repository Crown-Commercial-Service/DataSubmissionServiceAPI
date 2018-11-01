class Framework
  module Definition
    class RM1070 < Base
      framework_short_name 'RM1070'
      framework_name       'Vehicle Purchase (RM1070)'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT'

        field 'Lot Number', :string, exports_to: 'LotNumber', inclusion: { in: %w[1 2 3 4 5 6 7 8 9] }
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :string, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Invoice Line Number', :string
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Segment', :string, exports_to: 'ProductGroup'
        field 'UNSPSC', :string, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Invoice Price Per Vehicle', :string, exports_to: 'UnitPrice', numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity'
        field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT', :string, exports_to: 'InvoiceValue', numericality: true
        field 'Additional Expenditure to provide goods', :string, exports_to: 'Expenses', numericality: true, allow_nil: true
        field 'VAT Applicable?', :string, exports_to: 'VATIncluded', inclusion: { in: ['Y', 'N'], message: "Is VAT applicable on this product or service? Enter 'Y' or 'N'" }
        field 'VAT amount charged', :string, exports_to: 'VATCharged', numericality: true, allow_nil: true
        field 'Vehicle CAP Code', :string, exports_to: 'ProductCode'
        field 'Vehicle Trim/Derivative', :string, exports_to: 'ProductDescription'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Vehicle Registration Number', :string, exports_to: 'Additional1'
        field 'All Conversion and third party conversion costs excluding factory fit options', :string, exports_to: 'Additional2'
        field 'CO2 Emissions', :string, exports_to: 'Additional3'
        field 'Fuel Type', :string, exports_to: 'Additional4'
        field 'Customer Support Terms', :string, exports_to: 'Additional5'
        field 'Leasing Company', :string, exports_to: 'Additional6'
        field 'Additional support terms given to Lease companies', :string, exports_to: 'Additional7'
        field 'Invoice Price Excluding Options', :string, exports_to: 'Additional8', numericality: true, allow_nil: true
        field 'List Price Excluding Options', :string, numericality: true, allow_nil: true
        field 'eAuction Contract No', :string
      end
    end
  end
end

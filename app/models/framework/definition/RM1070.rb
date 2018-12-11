class Framework
  module Definition
    class RM1070 < Base
      framework_short_name 'RM1070'
      framework_name       'Vehicle Purchase (RM1070)'

      management_charge_rate BigDecimal('0.5')

      class Invoice < EntryData
        total_value_field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Invoice Line Number', :string
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Segment', :string, exports_to: 'ProductGroup'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Invoice Price Per Vehicle', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'Additional Expenditure to provide goods', :string, exports_to: 'Expenses', ingested_numericality: true, allow_nil: true
        field 'VAT Applicable?', :string, exports_to: 'VATIncluded', case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Vehicle CAP Code', :string, exports_to: 'ProductCode'
        field 'Vehicle Trim/Derivative', :string, exports_to: 'ProductDescription'
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Vehicle Registration Number', :string, exports_to: 'Additional1'
        field 'All Conversion and third party conversion costs excluding factory fit options', :string, exports_to: 'Additional2', ingested_numericality: true, allow_nil: true
        field 'CO2 Emissions', :string, exports_to: 'Additional3', ingested_numericality: true, allow_nil: true
        field 'Fuel Type', :string, exports_to: 'Additional4'
        field 'Customer Support Terms', :string, exports_to: 'Additional5'
        field 'Leasing Company', :string, exports_to: 'Additional6'
        field 'Additional support terms given to Lease companies', :string, exports_to: 'Additional7'
        field 'Invoice Price Excluding Options', :string, exports_to: 'Additional8', ingested_numericality: true, allow_nil: true
        field 'List Price Excluding Options', :string, ingested_numericality: true, allow_nil: true
        field 'eAuction Contract No', :string
      end
    end
  end
end

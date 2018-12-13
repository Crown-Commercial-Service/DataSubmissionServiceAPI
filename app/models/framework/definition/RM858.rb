class Framework
  module Definition
    class RM858 < Base
      framework_short_name 'RM858'
      framework_name       'Pan Govt Vehicle Leasing & Fleet Outsource Solutio'

      management_charge_rate BigDecimal('0.5')

      class Invoice < EntryData
        total_value_field 'Invoice Line Total Value ex VAT'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string
        field 'Invoice Line Product / Service Description', :string, exports_to: 'ProductDescription'
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit ex VAT', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Invoice Line Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Invoice Line Total Value ex VAT', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Applicable', :string, exports_to: 'VATIncluded', case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'VAT Amount Charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Spend Code', :string, exports_to: 'PromotionCode'
        field 'Invoice Line Product / Service Grouping', :string, exports_to: 'ProductGroup', presence: true
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
        field 'Lease Start Date', :string, ingested_date: true
        field 'Lease End Date', :string, ingested_date: true
        field 'Payment Profile', :string
        field 'Annual Lease Mileage', :string, allow_nil: true, ingested_numericality: true
        field 'Base Vehicle Price ex VAT', :string, allow_nil: true, ingested_numericality: true
        field 'Lease Cost excluding Optional Extras and Conversion ex VAT', :string, allow_nil: true, ingested_numericality: true
        field 'Lease Finance Charge ex VAT', :string, allow_nil: true, ingested_numericality: true
        field 'Lease Finance Margin ex VAT', :string, allow_nil: true, ingested_numericality: true
        field 'Vehicle Purchase Terms', :string
        field 'Standard Vehicle Discount (%)', :string, allow_nil: true, ingested_numericality: true
        field 'Enhanced Vehicle Discount (%)', :string, allow_nil: true, ingested_numericality: true
        field 'Annual Service Maintenance & Repair Costs ex VAT', :string, allow_nil: true, ingested_numericality: true
        field 'Annual Breakdown & Recovery Costs ex VAT', :string, allow_nil: true, ingested_numericality: true
        field 'Residual Value', :string, allow_nil: true, ingested_numericality: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
      end
    end
  end
end

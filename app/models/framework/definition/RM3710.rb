class Framework
  module Definition
    class RM3710 < Base
      framework_short_name 'RM3710'
      framework_name       'Vehicle Lease and Fleet Management'

      management_charge_rate BigDecimal('0.5')

      class Invoice < EntryData
        total_value_field 'Total Charge (Ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit (Ex VAT)', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Applicable', :string, exports_to: 'VATIncluded', case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'CAP Code', :string, exports_to: 'ProductCode'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass'
        field 'Product Description - Vehicle Derivative / Fleet Management Services', :string, exports_to: 'ProductDescription'
        field 'Product Classification', :string, exports_to: 'ProductGroup'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2', presence: true
        field 'Vehicle Registration', :string, exports_to: 'Additional1', presence: true
        field 'Fuel Type', :string, exports_to: 'Additional4'
        field 'CO2 Emission Levels', :string, exports_to: 'Additional3', ingested_numericality: true, allow_nil: true
        field 'Vehicle Convertors Name', :string, exports_to: 'Additional5'
        field 'Vehicle Conversion Type', :string, exports_to: 'Additional6'
        field 'Vehicle Type', :string, exports_to: 'Additional7'
        field 'Lease Start Date', :string, exports_to: 'Additional8', ingested_date: true, allow_nil: true
        field 'Lease End Date', :string, ingested_date: true, allow_nil: true
        field 'Lease Period (Months)', :string, ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Payment Profile', :string
        field 'Annual Lease Mileage', :string, ingested_numericality: true, allow_nil: true
        field 'Base Vehicle Price ex VAT', :string, ingested_numericality: true, allow_nil: true
        field 'Lease Finance Charge ex VAT', :string, ingested_numericality: true, allow_nil: true
        field 'Annual Service Maintenance & Repair Costs ex VAT', :string, ingested_numericality: true, allow_nil: true
        field 'Residual Value', :string, ingested_numericality: true, allow_nil: true
        field 'Total Manufacturer Discount (%)', :string, ingested_numericality: true, allow_nil: true
        field 'Spend Code', :string, exports_to: 'PromotionCode', inclusion: { in: ['Lease Rental', 'Fleet Management Fee', 'Damage', 'Other Re-charges'] }
      end
    end
  end
end

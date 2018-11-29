class Framework
  module Definition
    class RM807 < Base
      framework_short_name 'RM807'
      framework_name       'Vehicle Hire (RM807)'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Charges (ex VAT)'

        field 'Contract Number', :string
        field 'Cost Centre', :string
        field 'Miles Travelled', :string, exports_to: 'Additional6', allow_nil: true, ingested_numericality: true
        field 'Refuelling Charges inc fuel ex VAT', :string, exports_to: 'Additional7', allow_nil: true, ingested_numericality: true
        field 'Rental Company', :string, exports_to: 'Additional8'
        field 'Booking Method', :string
        field 'On line booking discount', :string, allow_nil: true, ingested_numericality: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Agreement Number/Reference', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string
        field 'Invoice Line Product/Service Description', :string, exports_to: 'ProductDescription'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', allow_nil: true, ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true
        field 'Invoice Line Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true
        field 'Total Charges (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Applicable', :string, exports_to: 'VATIncluded', presence: true, case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, allow_nil: true
        field 'Promotion Code', :string, exports_to: 'PromotionCode'
        field 'Invoice Line Product/Service Grouping', :string, exports_to: 'ProductGroup'
        field 'Rental Period', :string, exports_to: 'Additional1'
        field 'Vehicle Group Booked', :string, exports_to: 'Additional2'
        field 'Vehicle Group Supplied', :string, exports_to: 'Additional3'
        field 'Vehicle Make', :string, exports_to: 'ProductClass'
        field 'Vehicle Derivative', :string, exports_to: 'ProductSubClass'
        field 'Fuel Type', :string, exports_to: 'Additional4'
        field 'CO2 Emission Level', :string, exports_to: 'Additional5'
      end
    end
  end
end

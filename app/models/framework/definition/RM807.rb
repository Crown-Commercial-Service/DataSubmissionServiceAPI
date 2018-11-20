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
        field 'Miles Travelled', :decimal, exports_to: 'Additional6', allow_nil: true, numericality: true
        field 'Refuelling Charges inc fuel ex VAT', :decimal, exports_to: 'Additional7', allow_nil: true, numericality: true
        field 'Rental Company', :string, exports_to: 'Additional8'
        field 'Booking Method', :string
        field 'On line booking discount', :decimal, allow_nil: true, numericality: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Agreement Number/Reference', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Customer Invoice Line Number', :string, presence: true
        field 'Invoice Line Product/Service Description', :string, exports_to: 'ProductDescription', presence: true
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', allow_nil: true, numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Invoice Line Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Charges (ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT Applicable', :boolean, exports_to: 'VATIncluded', presence: true, inclusion: { in: %w[true false] }
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Promotion Code', :string, exports_to: 'PromotionCode'
        field 'Invoice Line Product/Service Grouping', :string, exports_to: 'ProductGroup', presence: true
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

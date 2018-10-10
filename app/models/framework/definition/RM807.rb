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
        field 'Miles Travelled', :decimal, exports_to: 'Additional6'
        field 'Refuelling Charges inc fuel ex VAT', :decimal, exports_to: 'Additional7'
        field 'Rental Company', :string, exports_to: 'Additional8'
        field 'Booking Method', :string
        field 'On line booking discount', :decimal
        field 'Lot Number', :string, exports_to: 'LotNumber'
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName'
        field 'Customer URN', :integer, exports_to: 'CustomerURN'
        field 'Customer Agreement Number/Reference', :string, exports_to: 'CustomerReferenceNumber'
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate'
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Customer Invoice Line Number', :string
        field 'Invoice Line Product/Service Description', :string, exports_to: 'ProductDescription'
        field 'UNSPSC', :integer, exports_to: 'UNSPSC'
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice'
        field 'Invoice Line Quantity', :decimal, exports_to: 'UnitQuantity'
        field 'Total Charges (ex VAT)', :decimal, exports_to: 'InvoiceValue'
        field 'VAT Applicable', :boolean, exports_to: 'VATIncluded'
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged'
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

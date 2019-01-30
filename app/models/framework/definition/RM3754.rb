class Framework
  module Definition
    class RM3754 < Base
      framework_short_name 'RM3754'
      framework_name       'Vehicle Telematics'

      management_charge_rate BigDecimal('0.5')

      class Invoice < EntryData
        total_value_field 'Total Charge (ex VAT)'

        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Product Description', :string, exports_to: 'ProductDescription'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Vehicle Registration No', :string, exports_to: 'Additional1'
        field 'Total Number of Units', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Total Charge (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'Payment Profile', :string, exports_to: 'Additional2'
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional3'
        field 'Cost Centre', :string
        field 'Contract Number', :string
      end
    end
  end
end

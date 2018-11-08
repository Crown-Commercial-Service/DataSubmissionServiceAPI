require 'csv'

module Export
  class Invoices < ToIO
    HEADER = %w[
      SubmissionID
      CustomerURN
      CustomerName
      CustomerPostcode
      InvoiceDate
      InvoiceNumber
      SupplierReferenceNumber
      CustomerReferenceNumber
      LotNumber
      ProductDescription
      ProductGroup
      ProductClass
      ProductSubClass
      ProductCode
      UnitType
      UnitPrice
      UnitQuantity
      InvoiceValue
      Expenses
      VATCharged
      PromotionCode
      ManagementChargeValue
      Additional1
      Additional2
      Additional3
      Additional4
      Additional5
      Additional6
      Additional7
      Additional8
    ].freeze
  end
end

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
    ].freeze
  end
end

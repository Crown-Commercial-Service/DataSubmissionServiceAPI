require 'csv'

module Export
  class Invoices < ToIo
    HEADER = %w[
      SubmissionID
      CustomerURN
      CustomerName
      CustomerPostCode
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
    ].concat(SubmissionEntryRow.additional_field_names).freeze
  end
end

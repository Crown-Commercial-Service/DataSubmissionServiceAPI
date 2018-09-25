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
    ].freeze
  end
end

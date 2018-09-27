require 'csv'

module Export
  class Contracts < ToIO
    HEADER = %w[
      SubmissionID
      CustomerURN
      CustomerName
      CustomerPostCode
      SupplierReferenceNumber
      CustomerReferenceNumber
      LotNumber
      ProductDescription
      ProductGroup
      ProductClass
      ProductSubClass
      ProductCode
      ProductLevel6
      CustomerContactName
      CustomerContactNumber
      CustomerContactEmail
    ].freeze
  end
end

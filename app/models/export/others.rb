require 'csv'

module Export
  class Others < ToIo
    HEADER = %w[
      SubmissionID
      CustomerURN
      CustomerName
      SupplierReferenceNumber
      CustomerReferenceNumber
      LotNumber
      ProductDescription
      ProductGroup
      ProductClass
      ProductSubClass
      ProductCode
    ].concat(SubmissionEntryRow.additional_field_names).freeze
  end
end

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
      ContractStartDate
      ContractEndDate
      ContractValue
      ContractAwardChannel
    ].concat(SubmissionEntriesStageRow.additional_field_names).freeze
  end
end

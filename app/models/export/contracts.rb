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

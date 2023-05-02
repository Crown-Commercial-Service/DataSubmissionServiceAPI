require 'csv'

module Export
  class Submissions < ToIo
    HEADER = %w[
      TaskID
      SubmissionID
      Status
      SubmissionType
      SubmissionFileType
      ContractEntryCount
      ContractValue
      InvoiceEntryCount
      InvoiceValue
      CCSManagementChargeValue
      CCSManagementChargeRate
      CreatedDate
      CreatedBy
      SupplierApprovedDate
      SupplierApprovedBy
      FinanceExportDate
      PONumber
    ].freeze
  end
end

require 'csv'

module Export
  class Submissions
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

    attr_reader :submissions, :output

    def initialize(submissions, output)
      @submissions = submissions
      @output = output
    end

    def run
      output.puts(CSV.generate_line(HEADER))
      submissions.each do |task|
        output.puts(Row.new(task).to_csv_line)
      end
    end
  end
end

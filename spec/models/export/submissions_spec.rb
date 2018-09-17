require 'rails_helper'
require 'stringio'

RSpec.describe Export::Submissions do
  context 'given valid submissions and an in-memory output' do
    let(:task) { create(:task) }

    let(:submission) do
      create(
        :submission,
        task: task,
        aasm_state: 'completed',
        entries: [
          create(:submission_entry),
          create(:submission_entry)
        ]
      )
    end

    let(:submissions) { [submission, create(:submission)] }

    let(:output) { StringIO.new }
    subject(:output_lines) { output.string.split("\n") }

    before do
      # Stub projected fields - fields that have been created by Export::Submissions::Extract
      allow_any_instance_of(Export::Submissions::Row).to receive(:invoice_entry_count).and_return(1)
      allow_any_instance_of(Export::Submissions::Row).to receive(:order_entry_count).and_return(1)
      Export::Submissions.new(submissions, output).run
    end

    it 'writes a header to that output' do
      expect(output_lines.first).to eql(
        'TaskID,SubmissionID,Status,SubmissionType,SubmissionFileType,ContractEntryCount,' \
        'ContractValue,InvoiceEntryCount,InvoiceValue,CCSManagementChargeValue,CCSManagementChargeRate,' \
        'CreatedDate,CreatedBy,SupplierApprovedDate,SupplierApprovedBy,FinanceExportDate,PONumber'
      )
    end

    it 'writes each submission to that output' do
      expect(output_lines.length).to eql(3)
      expect(output_lines[1]).to eql(
        <<~LINE.chomp
          #{submission.task.id},#{submission.id},supplier_accepted,file,#MISSING,1,#MISSING,1,#MISSING
        LINE
      )
    end
  end
end

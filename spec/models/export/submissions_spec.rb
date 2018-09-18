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
        created_at: Time.zone.local(2018, 9, 18, 14, 20, 35),
        management_charge: 450,
        purchase_order_number: 'PO1234',
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
      allow_any_instance_of(Export::Submissions::Row).to receive(:submission_file_type).and_return('xls')
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
        "#{submission.task.id},#{submission.id},supplier_accepted,file,xls,1,#MISSING,1,#MISSING,450," \
        '0.015,2018-09-18T14:20:35Z,,,,,PO1234'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Submissions::HEADER.length).to eql(
        Export::Submissions::Row.new(submission).row_values.length
      )
    end
  end
end

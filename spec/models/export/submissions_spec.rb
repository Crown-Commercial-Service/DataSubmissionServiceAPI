require 'rails_helper'
require 'stringio'

RSpec.describe Export::Submissions do
  context 'given some submissions and an in-memory output' do
    let!(:no_business_submission) do
      create(:no_business_submission)
    end

    let!(:submission) do
      create(
        :submission,
        aasm_state: 'completed',
        created_at: Time.zone.local(2018, 9, 18, 14, 20, 35),
        management_charge: 45000,
        purchase_order_number: 'PO1234',
        files: [
          create(:submission_file, :with_attachment)
        ],
        entries: [
          create(:invoice_entry),
          create(:order_entry)
        ]
      )
    end

    let(:extracted_submissions) { Export::Submissions::Extract.all_relevant }

    let(:output)           { StringIO.new }
    subject(:output_lines) { output.string.split("\n") }

    before do
      Export::Submissions.new(extracted_submissions, output).run
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
      expect(output_lines.find { |line| line.match('PO1234') }).to eql(
        "#{submission.task.id},#{submission.id},supplier_accepted,file,xls,1,#MISSING,1,#MISSING,450.00," \
        '0.015,2018-09-18T14:20:35Z,,,,,PO1234'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Submissions::HEADER.length).to eql(
        Export::Submissions::Row.new(extracted_submissions.first).row_values.length
      )
    end
  end
end

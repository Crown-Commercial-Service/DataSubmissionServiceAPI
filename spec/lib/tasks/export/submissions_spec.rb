require 'rails_helper'

RSpec.describe 'rake export:submissions', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  context 'no args are given' do
    let(:args) { {} }

    let!(:no_business_submission) do
      create(:no_business_submission, framework: create(:framework, short_name: 'RM3756'))
    end

    let!(:submission) do
      create(
        :submission,
        framework: create(:framework, short_name: 'RM3767'),
        aasm_state: 'completed',
        created_at: Time.zone.local(2018, 9, 18, 14, 20, 35),
        created_by: create(:user, name: 'CrForename CrSurname'),
        submitted_by: create(:user, name: 'SubForename SubSurname'),
        submitted_at: Time.zone.local(2018, 9, 20, 10, 11, 12),
        purchase_order_number: 'PO1234',
        files: [
          create(:submission_file, :with_attachment)
        ],
        entries: [
          create(:invoice_entry, total_value: 179.12, management_charge: 1.7912),
          create(:order_entry, total_value: 804.00)
        ]
      )
    end

    let(:extracted_submissions) { Export::Submissions::Extract.all_relevant }

    let(:output_filename) { '/tmp/submissions_20181225_000000.csv' }
    let(:output_lines)    { File.read(output_filename).split("\n") }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    before { task.execute(args) }
    after  { File.delete(output_filename) }

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
        "#{submission.task.id},#{submission.id},supplier_accepted,file,xls,1,804.00,1,179.12,1.79," \
        '#REMOVED,2018-09-18T14:20:35Z,CrForename CrSurname,2018-09-20T10:11:12Z,SubForename SubSurname,,PO1234'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Submissions::HEADER.length).to eql(
        Export::Submissions::Row.new(extracted_submissions.first).row_values.length
      )
    end
  end
end

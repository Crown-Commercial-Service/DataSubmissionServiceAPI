require 'rails_helper'

RSpec.describe Export::Relation do
  let(:logger)       { Logger.new(log_output) }
  let(:log_output)   { StringIO.new }
  let(:output_lines) { result.read.split("\n") }

  subject(:exporter) { Export::Relation.new(relation, logger) }

  around(:example) do |example|
    travel_to(Time.zone.local(2018, 12, 25, 15, 30, 12)) { example.run }
  end

  context 'there is nothing to export' do
    let(:relation) { Submission.all }
    let(:expected_filename) { '' }

    it 'tells us' do
      expect(exporter.run).to be_nil
      expect(log_output.string).to include('No submissions to export')
    end
  end

  context 'given the Export::Tasks::Extract.all_relevant Relation' do
    let!(:first_task)       { create(:task, status: :unstarted, period_year: 2018, period_month: 8) }
    let!(:second_task)      { create(:task) }
    let(:relation)          { Export::Tasks::Extract.all_relevant }

    let!(:result) { exporter.run }

    it 'returns a Tempfile' do
      expect(result).to be_a(Tempfile)
    end

    it 'tells us that it’s outputing tasks' do
      expect(log_output.string).to include('Exporting tasks')
    end

    it 'writes a header for the tasks export' do
      expect(output_lines.first).to eql(
        <<~HEADER.chomp
          TaskID,Month,SupplierID,FrameworkID,Status,TaskType,StartedDate,CompletedDate
        HEADER
      )
    end

    it 'writes each task to the export' do
      expect(output_lines.length).to eql(3)
      expect(output_lines.find { |l| l.match '2018-08' }).to eql(
        <<~LINE.chomp
          #{first_task.id},2018-08,#{first_task.supplier.salesforce_id},#{first_task.framework.short_name},unstarted,1,,
        LINE
      )
    end
  end

  context 'given the Export::Submissions::Extract.all_relevant Relation' do
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
        management_charge_total: 1.7912,
        files: [
          create(:submission_file, :with_attachment)
        ],
        entries: [
          create(:invoice_entry, total_value: 179.12),
          create(:order_entry, total_value: 804.00)
        ],
        staging_entries: [
          create(:invoice_entry_stage, total_value: 179.12),
          create(:order_entry_stage, total_value: 804.00)
        ]
      )
    end
    let(:relation) { Export::Submissions::Extract.all_relevant }

    let!(:result) { exporter.run }

    it 'returns a Tempfile' do
      expect(result).to be_a(Tempfile)
    end

    it 'tells us that it’s outputing tasks' do
      expect(log_output.string).to include('Exporting submissions')
    end

    it 'writes a header for the submissions export' do
      expect(output_lines.first).to eql(%w[
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
      ].join(','))
    end

    it 'writes each submission to the export' do
      expect(output_lines.length).to eql(3)

      submission_record = CSV.parse(output_lines.join("\n"), headers: true).find do |row|
        row['SubmissionType'] == 'file'
      end

      aggregate_failures do
        expect(submission_record.fetch('TaskID'))
          .to eq(submission.task.id)

        expect(submission_record.fetch('SubmissionID'))
          .to eq(submission.id)

        expect(submission_record.fetch('Status'))
          .to eq('supplier_accepted')

        expect(submission_record.fetch('SubmissionType'))
          .to eq('file')

        expect(submission_record.fetch('SubmissionFileType'))
          .to eq('xls')

        expect(submission_record.fetch('ContractEntryCount'))
          .to eq('1')

        expect(submission_record.fetch('ContractValue'))
          .to eq('804.00')

        expect(submission_record.fetch('InvoiceValue'))
          .to eq('179.12')

        expect(submission_record.fetch('CCSManagementChargeValue'))
          .to eq('1.79')

        expect(submission_record.fetch('CCSManagementChargeRate'))
          .to eq('#REMOVED')

        expect(submission_record.fetch('CreatedDate'))
          .to eq('2018-09-18T14:20:35Z')

        expect(submission_record.fetch('CreatedBy'))
          .to eq('CrForename CrSurname')

        expect(submission_record.fetch('SupplierApprovedDate'))
          .to eq('2018-09-20T10:11:12Z')

        expect(submission_record.fetch('SupplierApprovedBy'))
          .to eq('SubForename SubSurname')

        expect(submission_record.fetch('FinanceExportDate'))
          .to be_nil

        expect(submission_record.fetch('PONumber'))
          .to eq('PO1234')
      end
    end

    it 'has as many headers as row values' do
      expect(Export::Submissions::HEADER.length).to eql(
        Export::Submissions::Row.new(relation.first, {}).row_values.length
      )
    end
  end

  context 'given the Export::Invoices::Extract.all_relevant Relation' do
    let(:relation) { Export::Invoices::Extract.all_relevant }

    let(:framework) do
      source = File.read(Rails.root.join('spec', 'fixtures', 'RM3786v1.fdl'))
      create(:framework, short_name: 'RM3786v1', definition_source: source)
    end

    let!(:complete_submission) { create :submission, aasm_state: 'completed', framework: framework }

    let!(:invoice) do
      # Explicit times are necessary because Export::Invoices::Extract.all_relevant
      # relies on order(:created_date)
      create :invoice_entry_stage, :legal_framework_invoice_data, submission: complete_submission,
                                                            management_charge: 142.99,
                                                            created_at: Time.zone.local(2018, 12, 25, 13, 55, 59)
    end

    let!(:invoice2) do
      create :invoice_entry_stage, submission: complete_submission,
                             created_at: Time.zone.local(2018, 12, 25, 14, 55, 59)
    end

    let!(:result) { exporter.run }

    before do
      expect(invoice.created_at).to be < invoice2.created_at,
                                    'precondition: these specs depend on created_at order'
    end

    it 'returns a Tempfile' do
      expect(result).to be_a(Tempfile)
    end

    it 'tells us that it’s outputing invoices' do
      expect(log_output.string).to include('Exporting invoices')
    end

    it 'writes a header for the invoices export' do
      expect(output_lines.first).to eql(
        'SubmissionID,CustomerURN,CustomerName,CustomerPostCode,InvoiceDate,InvoiceNumber,'\
        'SupplierReferenceNumber,CustomerReferenceNumber,LotNumber,ProductDescription,'\
        'ProductGroup,ProductClass,ProductSubClass,ProductCode,UnitType,UnitPrice,UnitQuantity,'\
        'InvoiceValue,Expenses,VATCharged,PromotionCode,ManagementChargeValue,'\
        'Additional1,Additional2,Additional3,Additional4,Additional5,Additional6,Additional7,Additional8,'\
        'Additional9,Additional10,Additional11,Additional12,Additional13,Additional14,Additional15,Additional16,'\
        'Additional17,Additional18,Additional19,Additional20,Additional21,Additional22,Additional23,Additional24'
      )
    end

    it 'writes each invoice to the export' do
      expect(output_lines.length).to eql(3)
      expect(output_lines.second).to include(invoice.submission_id.to_s)
    end

    it 'writes #NOTINDATA for fields it cannot map' do
      expect(output_lines.find { |l| l.match 'NOTINDATA' }).to eql(
        "#{invoice.submission_id},#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,,,"\
        ',,,,,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,#NOTINDATA,,'\
        ',,,,,,,,,,,,,,,,,,,,,,,,'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Invoices::HEADER.length).to eql(
        Export::Invoices::Row.new(relation.first, {}).row_values.length
      )
    end
  end

  context 'given the Export::Contracts::Extract.all_relevant Relation' do
    let(:relation) { Export::Contracts::Extract.all_relevant }

    let(:framework) do
      source = File.read(Rails.root.join('spec', 'fixtures', 'RM3786v1.fdl'))
      create(:framework, short_name: 'RM3786v1', definition_source: source)
    end

    let!(:complete_submission) { create :submission, aasm_state: 'completed', framework: framework }

    let!(:contract) do
      # Explicit times are necessary because Export::Contracts::Extract.all_relevant
      # relies on order(:created_date)
      create :contract_entry_stage, :legal_framework_contract_data, submission: complete_submission,
                                                              created_at: Time.zone.local(2018, 12, 25, 13, 55, 59)
    end

    let!(:contract2) do
      create :contract_entry_stage, submission: complete_submission,
                              created_at: Time.zone.local(2018, 12, 25, 14, 55, 59)
    end

    let!(:result) { exporter.run }

    before do
      expect(contract.created_at).to be < contract2.created_at,
                                     'precondition: these specs depend on created_at order'
    end

    it 'returns a Tempfile' do
      expect(result).to be_a(Tempfile)
    end

    it 'tells us that it’s outputing contracts CSV' do
      expect(log_output.string).to include('Exporting contracts')
    end

    it 'writes a header for the contracts export' do
      expect(output_lines.first).to eql(
        'SubmissionID,CustomerURN,CustomerName,CustomerPostCode,SupplierReferenceNumber,'\
        'CustomerReferenceNumber,LotNumber,ProductDescription,ProductGroup,ProductClass,ProductSubClass,ProductCode,'\
        'ProductLevel6,CustomerContactName,CustomerContactNumber,CustomerContactEmail,'\
        'ContractStartDate,ContractEndDate,ContractValue,ContractAwardChannel,'\
        'Additional1,Additional2,Additional3,Additional4,Additional5,Additional6,Additional7,Additional8,'\
        'Additional9,Additional10,Additional11,Additional12,Additional13,Additional14,Additional15,Additional16,'\
        'Additional17,Additional18,Additional19,Additional20,Additional21,Additional22,Additional23,Additional24'
      )
    end

    it 'writes each contract to the export' do
      expect(output_lines.length).to eql(3)
      expect(output_lines).to include(
        "#{contract.submission_id},10010913,Government Legal Department,WC1B 4Z3,471600.00004,"\
        'DWP - Claim by Mr I Dontexist,1,Contentious Employment,,,,,,,,,'\
        '2019-06-27,2020-06-27,5000.00,Further Competition,N/A,N,Central Government Department,'\
        'N,0.00,15,,,,,,,,,,,,,,,,,,'
      )
    end

    it 'writes #NOTINDATA for fields it cannot map' do
      expect(output_lines.find { |l| l.match 'NOTINDATA' }).to eql(
        "#{contract2.submission_id},#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,#NOTINDATA," \
        ',,,,,,,,,,,' \
        '#NOTINDATA,#NOTINDATA,,,,,,,,,,,,,,,,,,,,,,,,'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Contracts::HEADER.length).to eql(
        Export::Contracts::Row.new(relation.first, {}).row_values.length
      )
    end
  end
end

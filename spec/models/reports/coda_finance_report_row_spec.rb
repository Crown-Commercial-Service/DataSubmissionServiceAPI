require 'rails_helper'

RSpec.describe Reports::CodaFinanceReportRow do
  let(:task) { FactoryBot.create(:task, framework: framework, supplier: supplier, period_month: 8, period_year: 2018) }
  let(:framework) { FactoryBot.create(:framework, coda_reference: 401234) }
  let(:supplier) { FactoryBot.create(:supplier, coda_reference: 'C012345') }
  let(:submission) { FactoryBot.create(:submission, framework: framework, task: task, supplier: supplier) }
  subject(:report_row) { Reports::CodaFinanceReportRow.new(submission) }

  it 'reports the framework’s coda_reference as ‘Nominal’' do
    expect(report_row.data['Nominal']).to eq framework.coda_reference
  end

  it 'reports the framework’ short_name as ‘Contract ID' do
    expect(report_row.data['Contract ID']).to eq framework.short_name
  end

  it 'reports the framework’ name as ‘Lot Description’' do
    expect(report_row.data['Lot Description']).to eq framework.name
  end

  it 'reports the supplier’s coda_reference as ‘Customer Code’' do
    expect(report_row.data['Customer Code']).to eq supplier.coda_reference
  end

  it 'reports the supplier’s name as ‘Customer Name’' do
    expect(report_row.data['Customer Name']).to eq supplier.name
  end

  it 'also reports the supplier’s name as ‘Submitter’ for now as we don’t record the submitting user' do
    expect(report_row.data['Submitter']).to eq supplier.name
  end

  it 'reports the task’s period in the format "Month YEAR" as ‘Month’' do
    expect(report_row.data['Month']).to eq 'August 2018'
  end

  describe 'the calculations' do
    before do
      # Entries for invoices raised
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'InvoicesRaised', row: 1 },
        data: { 'Total Cost (ex VAT)' => '801.50' }
      )
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'InvoicesRaised', row: 2 },
        data: { 'Total Cost (ex VAT)' => '428.95' }
      )
      # Entries for another sheet (i.e. ones that should be excluded from calculation)
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'OrdersReceived', row: 1 },
        data: { 'Total Cost (ex VAT)' => '1000.00' }
      )
    end

    it 'reports the total sales from the invoices sheet as ‘Inf Sales’' do
      expect(report_row.data['Inf Sales']).to eq '1230.45'
    end

    it 'reports the total management charge as ‘Commission’' do
      expect(report_row.data['Commission']).to eq '18.46'
    end

    it 'reports the management charge rate as ‘Commission %’' do
      expect(report_row.data['Commission %']).to eq '0.015'
    end
  end
end

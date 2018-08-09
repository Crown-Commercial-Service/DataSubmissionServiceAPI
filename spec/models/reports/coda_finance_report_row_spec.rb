require 'rails_helper'

RSpec.describe Reports::CodaFinanceReportRow do
  let(:task) { FactoryBot.create(:task, framework: framework, supplier: supplier, period_month: 8, period_year: 2018) }
  let(:framework) { FactoryBot.create(:framework, coda_reference: 401234) }
  let(:supplier) { FactoryBot.create(:supplier, coda_reference: 'C012345') }
  let(:submission) { FactoryBot.create(:submission, framework: framework, task: task, supplier: supplier) }
  subject(:cg_report_row) { Reports::CodaFinanceReportRow.new(submission, Customer.sectors[:central_government]) }
  subject(:wps_report_row) { Reports::CodaFinanceReportRow.new(submission, Customer.sectors[:wider_public_sector]) }

  it 'reports the framework’s coda_reference as ‘Nominal’' do
    expect(cg_report_row.data['Nominal']).to eq framework.coda_reference
  end

  it 'reports the framework’ short_name as ‘Contract ID' do
    expect(cg_report_row.data['Contract ID']).to eq framework.short_name
  end

  it 'reports the framework’ name as ‘Lot Description’' do
    expect(cg_report_row.data['Lot Description']).to eq framework.name
  end

  it 'reports the supplier’s coda_reference as ‘Customer Code’' do
    expect(cg_report_row.data['Customer Code']).to eq supplier.coda_reference
  end

  it 'reports the supplier’s name as ‘Customer Name’' do
    expect(cg_report_row.data['Customer Name']).to eq supplier.name
  end

  it 'also reports the supplier’s name as ‘Submitter’ for now as we don’t record the submitting user' do
    expect(cg_report_row.data['Submitter']).to eq supplier.name
  end

  it 'reports the task’s period in the format "Month YEAR" as ‘Month’' do
    expect(cg_report_row.data['Month']).to eq 'August 2018'
  end

  it 'reports the management charge rate as ‘Commission %’' do
    expect(cg_report_row.data['Commission %']).to eq '0.015'
  end

  it 'reports the sector as ‘End User’' do
    expect(cg_report_row.data['End User']).to eq 'UCGV'
    expect(wps_report_row.data['End User']).to eq 'UWPS'
  end

  describe 'the calculations' do
    let(:home_office) { FactoryBot.create(:customer, :central_government, name: 'Home Office') }
    let(:health_dept) { FactoryBot.create(:customer, :central_government, name: 'Department for Health') }
    let(:bobs_charity) { FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity') }

    let!(:home_office_invoice_entry) do
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'InvoicesRaised', row: 1 },
        data: { 'Total Cost (ex VAT)' => '801.50', 'Customer URN' => home_office.urn }
      )
    end
    let!(:health_dept_invoice_entry) do
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'InvoicesRaised', row: 2 },
        data: { 'Total Cost (ex VAT)' => '428.95', 'Customer URN' => health_dept.urn }
      )
    end
    let!(:bobs_charity_invoice_entry) do
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'InvoicesRaised', row: 2 },
        data: { 'Total Cost (ex VAT)' => '-428.95', 'Customer URN' => bobs_charity.urn }
      )
    end
    let!(:home_office_order_entry) do
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'OrdersReceived', row: 1 },
        data: { 'Total Cost (ex VAT)' => '1000.00', 'Customer URN' => home_office.urn }
      )
    end
    let!(:bobs_charity_order_entry) do
      FactoryBot.create(
        :validated_submission_entry,
        submission: submission,
        source: { sheet: 'OrdersReceived', row: 1 },
        data: { 'Total Cost (ex VAT)' => '1200.00', 'Customer URN' => bobs_charity.urn }
      )
    end

    it 'reports the total invoiced sales, scoped to the sector, as ‘Inf Sales’' do
      expect(cg_report_row.data['Inf Sales']).to eq '1230.45'
      expect(wps_report_row.data['Inf Sales']).to eq '-428.95'
    end

    it 'reports the total management charge, scoped to the sector, as ‘Commission’' do
      expect(cg_report_row.data['Commission']).to eq '18.46'
      expect(wps_report_row.data['Commission']).to eq '-6.43'
    end
  end
end

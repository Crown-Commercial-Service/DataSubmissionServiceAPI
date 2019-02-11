require 'rails_helper'

RSpec.describe Export::CodaFinanceReport::Row do
  let(:task) { FactoryBot.create(:task, framework: framework, supplier: supplier, period_month: 8, period_year: 2018) }
  let(:framework) { FactoryBot.create(:framework, short_name: 'RM1070', coda_reference: 401234) }
  let(:supplier) { FactoryBot.create(:supplier, coda_reference: 'C012345') }
  let(:submission) do
    FactoryBot.create(
      :submission,
      framework: framework,
      task: task,
      supplier: supplier,
      purchase_order_number: 'PO999'
    )
  end
  subject(:cg_report_row) { Export::CodaFinanceReport::Row.new(submission, Customer.sectors[:central_government]) }
  subject(:wps_report_row) { Export::CodaFinanceReport::Row.new(submission, Customer.sectors[:wider_public_sector]) }

  it 'reports the submission ID as ‘RunID’' do
    expect(cg_report_row.run_id).to eq submission.id
  end

  it 'reports the framework’s coda_reference as ‘Nominal’' do
    expect(cg_report_row.nominal).to eq framework.coda_reference
  end

  it 'reports the framework’ short_name as ‘Contract ID' do
    expect(cg_report_row.contract_id).to eq framework.short_name
  end

  it '#order_number returns the submission’s purchase_order_number' do
    expect(cg_report_row.order_number).to eq 'PO999'
  end

  it 'reports the framework’ name as ‘Lot Description’' do
    expect(cg_report_row.lot_description).to eq framework.name
  end

  it 'reports the supplier’s coda_reference as ‘Customer Code’' do
    expect(cg_report_row.customer_code).to eq supplier.coda_reference
  end

  it 'reports the supplier’s name as ‘Customer Name’' do
    expect(cg_report_row.customer_name).to eq supplier.name
  end

  it 'also reports the supplier’s name as ‘Submitter’ for now as we don’t record the submitting user' do
    expect(cg_report_row.submitter).to eq supplier.name
  end

  it 'reports the task’s period in the format "Month YEAR" as ‘Month’' do
    expect(cg_report_row.month).to eq 'August 2018'
  end

  it 'reports the sector as ‘End User’' do
    expect(cg_report_row.end_user).to eq 'UCGV'
    expect(wps_report_row.end_user).to eq 'UWPS'
  end

  describe 'the calculations' do
    let(:home_office) { FactoryBot.create(:customer, :central_government, name: 'Home Office') }
    let(:health_dept) { FactoryBot.create(:customer, :central_government, name: 'Department for Health') }
    let(:bobs_charity) { FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity') }

    let!(:home_office_invoice_entry) do
      FactoryBot.create(
        :invoice_entry,
        :valid,
        submission: submission,
        customer_urn: home_office.urn,
        total_value: 801.50,
        management_charge: 4.00
      )
    end
    let!(:health_dept_invoice_entry) do
      FactoryBot.create(
        :invoice_entry,
        :valid,
        submission: submission,
        customer_urn: health_dept.urn,
        total_value: 428.95,
        management_charge: 2.1447
      )
    end
    let!(:bobs_charity_invoice_entry) do
      FactoryBot.create(
        :invoice_entry,
        :valid,
        submission: submission,
        customer_urn: bobs_charity.urn,
        total_value: -428.95,
        management_charge: -2.1447
      )
    end
    let!(:home_office_order_entry) do
      FactoryBot.create(
        :order_entry,
        :valid,
        submission: submission,
        customer_urn: home_office.urn,
        total_value: 1000,
        management_charge: 5
      )
    end
    let!(:bobs_charity_order_entry) do
      FactoryBot.create(
        :order_entry,
        :valid,
        submission: submission,
        customer_urn: bobs_charity.urn,
        total_value: 1200,
        management_charge: 6
      )
    end

    it 'reports the total invoiced sales, scoped to the sector, as ‘Inf Sales’' do
      expect(cg_report_row.inf_sales).to eq '1230.45'
      expect(wps_report_row.inf_sales).to eq '-428.95'
    end

    it 'reports the total management charge to 2dp, scoped to the sector, as ‘Commission’' do
      expect(cg_report_row.commission).to eq '6.14'
      expect(wps_report_row.commission).to eq '-2.14'
    end

    it 'handles no business submissions, reporting them as zero sales and commission' do
      no_business_submission = FactoryBot.create(:no_business_submission, framework: framework)
      row = Export::CodaFinanceReport::Row.new(no_business_submission, Customer.sectors[:central_government])

      expect(row.inf_sales).to eq '0.00'
      expect(row.commission).to eq '0.00'
    end
  end
end

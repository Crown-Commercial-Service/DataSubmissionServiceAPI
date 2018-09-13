require 'rails_helper'

RSpec.describe Export::CodaFinanceReport do
  let(:home_office) { FactoryBot.create(:customer, :central_government, name: 'Home Office') }
  let(:framework) { FactoryBot.create(:framework, coda_reference: 409999, name: 'G CLOUD', short_name: 'RM3787') }
  let(:task_1) do
    FactoryBot.create(:task, framework: framework, supplier: supplier_1, period_month: 8, period_year: 2018)
  end
  let(:task_2) do
    FactoryBot.create(:task, framework: framework, supplier: supplier_2, period_month: 8, period_year: 2018)
  end
  let(:supplier_1) { FactoryBot.create(:supplier, name: 'Bob', coda_reference: 'C099999') }
  let(:supplier_2) { FactoryBot.create(:supplier, name: 'Mary', coda_reference: 'C011111') }

  let(:no_business_submission) do
    FactoryBot.create(:no_business_submission, framework: framework, supplier: supplier_1, task: task_1)
  end
  let(:submission) do
    FactoryBot.create(
      :submission,
      entries: [submission_entry_1, submission_entry_2],
      supplier: supplier_2,
      framework: framework,
      task: task_1
    )
  end
  let(:submission_entry_1) do
    FactoryBot.build(
      :validated_invoice_submission_entry,
      data: { 'Total Cost (ex VAT)' => '678.55', 'Customer URN' => home_office.urn },
      source: { sheet: 'InvoicesRaised', row: 1 }
    )
  end
  let(:submission_entry_2) do
    FactoryBot.build(
      :validated_invoice_submission_entry,
      data: { 'Total Cost (ex VAT)' => '123.45', 'Customer URN' => home_office.urn },
      source: { sheet: 'InvoicesRaised', row: 2 }
    )
  end

  let(:submissions)      { [submission, no_business_submission] }
  let(:output)           { StringIO.new }
  let(:report)           { Export::CodaFinanceReport.new(submissions, output) }
  let(:report_timestamp) { Time.zone.now.to_i }

  let(:expected_csv) do
    <<~CSV
      RunID,Nominal,Customer Code,Customer Name,Contract ID,Order Number,Lot Description,Inf Sales,Commission,Commission %,End User,Submitter,Month,M_Q
      #{submission.id},409999,C011111,Mary,RM3787,,G CLOUD,802.00,12.03,0.015,UCGV,Mary,August 2018,M
      #{submission.id},409999,C011111,Mary,RM3787,,G CLOUD,0.00,0.00,0.015,UWPS,Mary,August 2018,M
      #{no_business_submission.id},409999,C099999,Bob,RM3787,,G CLOUD,0.00,0.00,0.015,UCGV,Bob,August 2018,M
      #{no_business_submission.id},409999,C099999,Bob,RM3787,,G CLOUD,0.00,0.00,0.015,UWPS,Bob,August 2018,M
    CSV
  end

  around(:example) do |example|
    freeze_time { example.run }
  end

  it 'generates a CSV file based on the submissions provided' do
    report.run
    expect(output.string).to eq expected_csv
  end
end

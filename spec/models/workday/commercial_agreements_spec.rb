require 'rails_helper'

RSpec.describe Workday::CommercialAgreements do
  before do
    allow(Workday).to receive(:tenant).and_return('tenant')
    allow(Workday).to receive(:username).and_return('user')
    allow(Workday).to receive(:api_password).and_return('password')
    stub_request(:get, 'https://wd3-impl-services1.workday.com/ccx/service/customreport2/tenant/INT003_ISU/CR_INT003_Commercial_Agreement_Cost_Center_and_Revenue_Category')
      .with(headers: { 'Authorization' => 'Basic dXNlcjpwYXNzd29yZA==' })
      .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'revenue_categories.xml')))
  end

  describe '#revenue_category_ids' do
    it 'should return Revenue Category IDs' do
      expect(subject.revenue_category_ids).to eq(
        'A206100' => 'CAH_Workplace'
      )
    end
  end

  describe '#tax_code_ids' do
    it 'should return Tax Code IDs' do
      expect(subject.tax_code_ids).to eq(
        'A206100' => 'GBC20'
      )
    end
  end
end

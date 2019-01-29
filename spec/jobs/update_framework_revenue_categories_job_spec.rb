require 'rails_helper'

RSpec.describe UpdateFrameworkRevenueCategoriesJob do
  describe '#perform' do
    let!(:framework) { FactoryBot.create(:framework, short_name: 'A206100') }

    before do
      allow(Workday).to receive(:tenant).and_return('tenant')
      stub_request(:get, 'https://wd3-impl-services1.workday.com/ccx/service/customreport2/tenant/INT003_ISU/CR_INT003_Commercial_Agreement_Cost_Center_and_Revenue_Category')
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'revenue_categories.xml')))
    end

    it 'should update the revenue category level WID' do
      UpdateFrameworkRevenueCategoriesJob.perform_now
      framework.reload
      expect(framework.revenue_category_wid).to eq('d19d3c5849dc016765bbae8dfc141ba8')
    end
  end
end

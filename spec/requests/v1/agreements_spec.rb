require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /agreements' do
    it 'creates an agreement between the given framework and supplier' do
      framework = FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')
      supplier  = FactoryBot.create(:supplier, name: 'Cheesy Does It')

      post "/v1/agreements?framework_id=#{framework.id}&supplier_id=#{supplier.id}"

      expect(response).to be_successful

      agreement = Agreement.first
      expect(agreement.framework).to eql framework
      expect(agreement.supplier).to eql supplier
    end
  end
end

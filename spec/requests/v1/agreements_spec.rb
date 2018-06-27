require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /agreements' do
    it 'creates an agreement between the given framework and supplier' do
      framework = FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')
      supplier  = FactoryBot.create(:supplier, name: 'Cheesy Does It')

      post "/v1/agreements?framework_id=#{framework.id}&supplier_id=#{supplier.id}"

      expect(response).to have_http_status(:created)

      agreement = Agreement.first

      expect(json['data']).to have_id(agreement.id)
      expect(json['data']).to have_attribute(:framework_id).with_value(framework.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
    end
  end
end

require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /memberships' do
    it 'returns a list of memberships' do
      supplier1 = FactoryBot.create(:supplier)
      supplier2 = FactoryBot.create(:supplier)
      user_id = '08223870-9ea3-4250-a14f-9b80ab466afb'

      Membership.create!(user_id: user_id, supplier: supplier1)
      Membership.create!(user_id: user_id, supplier: supplier2)

      get '/v1/memberships'

      expect(response).to have_http_status(:ok)

      expect(json['data'][0]).to have_attribute(:user_id).with_value(user_id)
      expect(json['data'][0]).to have_attribute(:supplier_id).with_value(supplier1.id)

      expect(json['data'][1]).to have_attribute(:user_id).with_value(user_id)
      expect(json['data'][1]).to have_attribute(:supplier_id).with_value(supplier2.id)
    end
  end
end

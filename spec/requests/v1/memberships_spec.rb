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

    it 'can be filtered by supplier_id' do
      supplier1 = FactoryBot.create(:supplier)
      supplier2 = FactoryBot.create(:supplier)

      user_id = 'e3913698-f379-4004-9dd8-98053f629a00'

      Membership.create!(supplier: supplier1, user_id: user_id)
      Membership.create!(supplier: supplier2, user_id: user_id)

      get "/v1/memberships?filter[supplier_id]=#{supplier1.id}"

      expect(response).to have_http_status(:ok)

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:supplier_id).with_value(supplier1.id)
      expect(json['data'][0]).to have_attribute(:user_id).with_value(user_id)
    end

    it 'can be filtered by user_id' do
      supplier = FactoryBot.create(:supplier)

      included_user_id = 'e3913698-f379-4004-9dd8-98053f629a00'
      excluded_user_id = '2f0c98f2-5ce3-4ce3-9214-159cb2dbe276'

      Membership.create!(supplier: supplier, user_id: included_user_id)
      Membership.create!(supplier: supplier, user_id: excluded_user_id)

      get "/v1/memberships?filter[user_id]=#{included_user_id}"

      expect(response).to have_http_status(:ok)

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data'][0]).to have_attribute(:user_id).with_value(included_user_id)
    end
  end
end

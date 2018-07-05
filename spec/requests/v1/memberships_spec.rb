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

  describe 'POST /memberships' do
    it 'creates a membership, which links a supplier to a user' do
      supplier = FactoryBot.create(:supplier)
      user_id = '7f77d6f6-1cca-4a58-9030-10a93fe1f32d'

      params = {
        data: {
          type: 'memberships',
          relationships: {
            supplier: {
              data: {
                type: 'suppliers',
                id: supplier.id
              }
            },
            user: {
              data: {
                type: 'users',
                id: user_id
              }
            }
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post '/v1/memberships', params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      membership = Membership.first

      expect(json['data']).to have_id(membership.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data']).to have_attribute(:user_id).with_value(user_id)
    end
  end
end

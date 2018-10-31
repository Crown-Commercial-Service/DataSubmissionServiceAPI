require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /memberships' do
    it 'returns a list of memberships' do
      supplier1 = FactoryBot.create(:supplier)
      supplier2 = FactoryBot.create(:supplier)
      user = FactoryBot.create(:user)

      Membership.create!(user: user, supplier: supplier1)
      Membership.create!(user: user, supplier: supplier2)

      get '/v1/memberships'

      expect(response).to have_http_status(:ok)

      expect(json['data'][0]).to have_attribute(:user_id).with_value(user.id)
      expect(json['data'][0]).to have_attribute(:supplier_id).with_value(supplier1.id)

      expect(json['data'][1]).to have_attribute(:user_id).with_value(user.id)
      expect(json['data'][1]).to have_attribute(:supplier_id).with_value(supplier2.id)
    end

    it 'can be filtered by supplier_id' do
      supplier1 = FactoryBot.create(:supplier)
      supplier2 = FactoryBot.create(:supplier)

      user = FactoryBot.create(:user)

      Membership.create!(supplier: supplier1, user: user)
      Membership.create!(supplier: supplier2, user: user)

      get "/v1/memberships?filter[supplier_id]=#{supplier1.id}"

      expect(response).to have_http_status(:ok)

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:supplier_id).with_value(supplier1.id)
      expect(json['data'][0]).to have_attribute(:user_id).with_value(user.id)
    end

    it 'can be filtered by user_id' do
      supplier = FactoryBot.create(:supplier)

      included_user = FactoryBot.create(:user)
      excluded_user = FactoryBot.create(:user)

      Membership.create!(supplier: supplier, user_id: included_user.id)
      Membership.create!(supplier: supplier, user_id: excluded_user.id)

      get "/v1/memberships?filter[user_id]=#{included_user.id}"

      expect(response).to have_http_status(:ok)

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data'][0]).to have_attribute(:user_id).with_value(included_user.id)
    end
  end

  describe 'POST /memberships' do
    it 'creates a membership, which links a supplier to a user' do
      supplier = FactoryBot.create(:supplier)
      user = FactoryBot.create(:user)

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
                id: user.id
              }
            }
          }
        }
      }

      post '/v1/memberships', params: params.to_json, headers: json_headers

      expect(response).to have_http_status(:created)

      membership = Membership.first

      expect(json['data']).to have_id(membership.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data']).to have_attribute(:user_id).with_value(user.id)
    end
  end

  describe 'DELETE /memberships/:membership_id' do
    it 'deletes a membership, disassociating a user from a supplier' do
      membership = FactoryBot.create(:membership)

      expect do
        delete "/v1/memberships/#{membership.id}", params: {}, headers: json_headers
      end.to change { Membership.count }.from(1).to(0)
    end
  end
end

require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  describe 'GET /v1/customers' do
    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/agreements', headers: { 'X-Auth-Id' => user.auth_id }
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/agreements' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/agreements', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => user.auth_id
        }
        expect(response).to be_successful
      end
    end

    it 'returns a list of customers' do
      customer1 = FactoryBot.create(:customer, :central_government, name: 'Home Office') 
      customer2 = FactoryBot.create(:customer, :central_government, name: 'Department for Health', published: false)
      customer3 = FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity')
  
      get '/v1/customers', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(customer1.id, customer3.id)

      json_customer = json['data'].find { |data| data['id'] == customer1.id }
      expect(json_customer).to have_attribute(:urn).with_value(customer1.urn)
      expect(json_customer).to have_attribute(:postcode).with_value(customer1.postcode)
    end
  end
end
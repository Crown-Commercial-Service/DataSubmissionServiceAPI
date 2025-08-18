require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  describe 'GET /v1/suppliers' do
    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/suppliers', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/suppliers' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/suppliers', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => JWT.encode(user.auth_id, 'test')
        }
        expect(response).to be_successful
      end
    end

    it 'returns a list of suppliers' do
      supplier1 = FactoryBot.create(:supplier, name: 'Supplier One')
      supplier2 = FactoryBot.create(:supplier, name: 'Supplier Two')
      user.suppliers << supplier1
      user.suppliers << supplier2

      get '/v1/suppliers', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(supplier1.id, supplier2.id)

      json_supplier = json['data'].find { |data| data['id'] == supplier1.id }
      expect(json_supplier).to have_attribute(:name).with_value(supplier1.name)
    end
  end
end

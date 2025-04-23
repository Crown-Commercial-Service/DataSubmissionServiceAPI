require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  describe 'GET /v1/notifications' do
    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/notifications', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/notifications' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/notifications', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => JWT.encode(user.auth_id, 'test')
        }
        expect(response).to be_successful
      end
    end

    it 'returns the details of the current published notification' do
      FactoryBot.create(:notification, published: true, summary: 'Testy McTestface',
notification_message: 'The answer is 42')

      get '/v1/notifications', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(json['data'])
        .to have_attribute(:summary)
      expect(json['data'])
        .to have_attribute(:notification_message)
    end
  end
end

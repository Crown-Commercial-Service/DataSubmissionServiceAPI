require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  describe 'GET /v1/release_notes' do
    subject(:data) { json['data'] }

    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/release_notes', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/release_notes' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/release_notes', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => JWT.encode(user.auth_id, 'test')
        }
        expect(response).to be_successful
      end
    end

    it 'returns the details of published release notes' do
      FactoryBot.create(:release_note, published: true)
      FactoryBot.create(:release_note, published: true)
      FactoryBot.create(:release_note, published: false)

      get '/v1/release_notes', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(data.size).to eq(2)
      expect(data.first).to have_attributes(:header, :body)
    end
  end

  describe 'GET /release_notes/:id' do
    it 'returns the requested release note' do
      release_note = FactoryBot.create(:release_note, published: true)

      get "/v1/release_notes/#{release_note.id}", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data']).to have_id(release_note.id)
    end
  end
end

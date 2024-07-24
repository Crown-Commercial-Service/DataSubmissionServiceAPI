require 'rails_helper'

RSpec.describe 'V2::Frameworks', type: :request do
  let(:valid_api_key) { create(:api_key) }
  let(:invalid_api_key) { 'invalid_key' }

  describe 'GET /v2/frameworks' do
    context 'with valid API key' do
      before do
        create_list(:framework, 3)
        get v2_frameworks_path, headers: { 'API-Key' => valid_api_key.key }
      end

      it 'returns a list of frameworks' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'with missing API key' do
      before { get v2_frameworks_path }

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('API key is missing')
      end
    end

    context 'with invalid API key' do
      before { get v2_frameworks_path, headers: { 'API-Key' => invalid_api_key } }

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('API key is invalid')
      end
    end
  end
end

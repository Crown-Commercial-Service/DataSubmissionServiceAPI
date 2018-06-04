require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /files/:file_id/entries' do
    it 'stores a submission entry, associated with a file' do
      file = FactoryBot.create(:submission_file)

      params = {
        source: { sheet: 'InvoicesReceived', row: 42 },
        data: { test: 'test' }
      }

      headers = {
        'CONTENT_TYPE': 'application/json'
      }

      post "/v1/files/#{file.id}/entries", params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      entry = SubmissionEntry.first

      expect(json['id']).to eql entry.id
      expect(json['source']['sheet']).to eql 'InvoicesReceived'
      expect(json['source']['row']).to eql 42
      expect(json['data']['test']).to eql 'test'
    end

    it 'returns an error if the "data" parameter is omitted' do
      file = FactoryBot.create(:submission_file)

      params = {
        source: { sheet: 'Orders', row: 1 }
      }

      headers = {
        'CONTENT_TYPE': 'application/json'
      }

      post "/v1/files/#{file.id}/entries", params: params.to_json, headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end
end

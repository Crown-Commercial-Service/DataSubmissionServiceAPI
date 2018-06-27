require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /files/:file_id/entries' do
    it 'stores a submission entry, associated with a file' do
      file = FactoryBot.create(:submission_file)

      params = {
        data: {
          type: 'submission_entries',
          attributes: {
            source: {
              sheet: 'InvoicesReceived',
              row: 42
            },
            data: {
              test: 'test'
            }
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post "/v1/files/#{file.id}/entries", params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      entry = SubmissionEntry.first

      expect(json['data']).to have_id(entry.id)

      expect(json['data']).to have_attribute(:submission_file_id).with_value(file.id)
      expect(json['data']).to have_attribute(:submission_id).with_value(file.submission.id)

      expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'InvoicesReceived'
      expect(json.dig('data', 'attributes', 'source', 'row')).to eql 42
      expect(json.dig('data', 'attributes', 'data', 'test')).to eql 'test'
    end

    it 'returns an error if the "data" parameter is omitted' do
      file = FactoryBot.create(:submission_file)

      params = {
        data: {
          type: 'submission_entries',
          attributes: {
            source: {
              sheet: 'Orders',
              row: 1
            }
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post "/v1/files/#{file.id}/entries", params: params.to_json, headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /files/:file_id/entries/:id' do
    it 'retrieves a submission entry data associated with a file' do
      submission = FactoryBot.create(:submission)
      file = FactoryBot.create(:submission_file, submission_id: submission.id)
      entry = FactoryBot.create(:submission_entry,
                                submission_id: submission.id,
                                submission_file_id: file.id,
                                source: { sheet: 'Orders', row: 23 },
                                data: { test: 'test' })

      get "/v1/files/#{file.id}/entries/#{entry.id}"

      expect(response).to have_http_status(:ok)

      expect(json['data']).to have_id(entry.id)

      expect(json['data']).to have_attribute(:submission_file_id).with_value(file.id)
      expect(json['data']).to have_attribute(:submission_id).with_value(file.submission.id)

      expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'Orders'
      expect(json.dig('data', 'attributes', 'source', 'row')).to eql 23
      expect(json.dig('data', 'attributes', 'data', 'test')).to eql 'test'
    end
  end
end

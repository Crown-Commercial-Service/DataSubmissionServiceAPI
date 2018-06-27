require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /submissions' do
    it 'creates a new submission and returns its id' do
      framework = FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')
      supplier  = FactoryBot.create(:supplier, name: 'Cheesy Does It')

      post "/v1/submissions?framework_id=#{framework.id}&supplier_id=#{supplier.id}"

      expect(response).to have_http_status(:created)

      submission = Submission.first

      expect(json['data']).to have_id(submission.id)
      expect(json['data']).to have_attribute(:framework_id).with_value(framework.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
    end
  end

  describe 'POST /submissions/:submission_id/files' do
    it 'creates a new submission file and returns its id' do
      submission = FactoryBot.create(:submission)

      post "/v1/submissions/#{submission.id}/files"

      expect(response).to have_http_status(:created)

      file = SubmissionFile.first

      expect(json['data']).to have_id(file.id)
      expect(json['data']).to have_attribute(:submission_id).with_value(submission.id)
    end
  end

  describe 'PATCH /submission/:submission_id/files/:file_id' do
    it 'updates a submission file' do
      submission = FactoryBot.create(:submission)
      file = FactoryBot.create(:submission_file, submission: submission)

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      patch "/v1/submissions/#{submission.id}/files/#{file.id}", params: {}, headers: headers

      expect(response).to have_http_status(204)
    end
  end

  describe 'POST /submissions/:submission_id/entries' do
    it 'stores a submission entry, not associated with a file' do
      submission = FactoryBot.create(:submission)

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

      post "/v1/submissions/#{submission.id}/entries", params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      entry = SubmissionEntry.first

      expect(json['data']).to have_id(entry.id)

      expect(json['data']).to have_attribute(:submission_id).with_value(submission.id)
      expect(json['data']).to have_attribute(:submission_file_id).with_value(nil)

      expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'InvoicesReceived'
      expect(json.dig('data', 'attributes', 'source', 'row')).to eql 42
      expect(json.dig('data', 'attributes', 'data', 'test')).to eql 'test'
    end
  end
end

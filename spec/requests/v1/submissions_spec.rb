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
      expect(json['id']).to eql file.id
      expect(json['submission_id']).to eql submission.id
    end
  end

  describe 'POST /submissions/:submission_id/entries' do
    it 'stores a submission entry, not associated with a file' do
      submission = FactoryBot.create(:submission)

      params = {
        source: { sheet: 'InvoicesReceived', row: 42 },
        data: { test: 'test' }
      }

      headers = {
        'CONTENT_TYPE': 'application/json'
      }

      post "/v1/submissions/#{submission.id}/entries", params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      entry = SubmissionEntry.first

      expect(json['id']).to eql entry.id
      expect(json['submission_id']).to eql submission.id
      expect(json['submission_file_id']).to be_nil

      expect(json['source']['sheet']).to eql 'InvoicesReceived'
      expect(json['source']['row']).to eql 42
      expect(json['data']['test']).to eql 'test'
    end
  end
end

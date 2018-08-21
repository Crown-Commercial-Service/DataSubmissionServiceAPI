require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /submissions/:submission_id/files' do
    it 'creates a new submission file and returns its id' do
      submission = FactoryBot.create(:submission)

      post "/v1/submissions/#{submission.id}/files", params: {}, headers: json_headers

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

      params = {
        data: {
          type: 'submission_files',
          attributes: {
            rows: 1000
          }
        }
      }

      patch "/v1/submissions/#{submission.id}/files/#{file.id}", params: params.to_json, headers: json_headers

      expect(response).to have_http_status(204)
      expect(file.reload.rows).to eql 1000
    end
  end

  describe 'GET /submissions/:submission_id/files/:id' do
    it 'retrieves a submission file data associated with a submission' do
      submission = FactoryBot.create(:submission)
      file = FactoryBot.create(:submission_file, submission_id: submission.id, rows: 40)

      get "/v1/submissions/#{submission.id}/files/#{file.id}"

      expect(response).to have_http_status(:ok)

      expect(json['data']).to have_id(file.id)

      expect(json['data']).to have_attribute(:rows).with_value(file.rows)
    end
  end
end

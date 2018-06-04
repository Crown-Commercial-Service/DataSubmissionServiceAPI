require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /submissions' do
    it 'creates a new submission and returns its id' do
      framework = FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')
      supplier  = FactoryBot.create(:supplier, name: 'Cheesy Does It')

      post "/v1/submissions?framework_id=#{framework.id}&supplier_id=#{supplier.id}"

      expect(response).to have_http_status(:created)

      submission = Submission.first
      expect(json['id']).to eql submission.id
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
end

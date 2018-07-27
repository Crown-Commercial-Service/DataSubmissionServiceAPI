require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /submissions/:submission_id' do
    it 'returns the requested submission' do
      submission = FactoryBot.create(:submission)

      get "/v1/submissions/#{submission.id}"

      expect(response).to be_successful

      expect(json['data']).to have_id(submission.id)
    end

    it 'optionally includes submission entries' do
      submission = FactoryBot.create(:submission)
      file = FactoryBot.create(:submission_file)
      entry = FactoryBot.create(:submission_entry,
                                submission: submission,
                                submission_file: file,
                                source: { sheet: 'Orders', row: 23 },
                                data: { test: 'test' })

      get "/v1/submissions/#{submission.id}?include=entries"

      expect(response).to be_successful
      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:entries)
        .with_data([{ 'id' => entry.id, 'type' => 'submission_entries' }])
      expect(json['included'][0])
        .to have_attribute(:submission_file_id).with_value(file.id)
      expect(json['included'][0].dig('attributes', 'source', 'sheet')).to eql 'Orders'
      expect(json['included'][0].dig('attributes', 'source', 'row')).to eql 23
      expect(json['included'][0].dig('attributes', 'data', 'test')).to eql 'test'
    end

    it 'optionally includes submission files' do
      submission = FactoryBot.create(:submission)
      file = FactoryBot.create(:submission_file, submission: submission)

      get "/v1/submissions/#{submission.id}?include=files"

      expect(response).to be_successful
      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:files)
        .with_data([{ 'id' => file.id, 'type' => 'submission_files' }])
    end

    it 'optionally includes submission framework' do
      framework = FactoryBot.create(:framework, short_name: 'RM1234')
      submission = FactoryBot.create(:submission, framework: framework)

      get "/v1/submissions/#{submission.id}?include=framework"
      expect(response).to be_successful

      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:framework)
        .with_data('id' => framework.id, 'type' => 'frameworks')
      expect(json['included'][0].dig('attributes', 'short_name')).to eql 'RM1234'
    end
  end

  describe 'POST /submissions' do
    it 'creates a new submission and returns its id' do
      framework = FactoryBot.create(:framework)
      supplier  = FactoryBot.create(:supplier)
      task = FactoryBot.create(:task, framework: framework, supplier: supplier)

      params = {
        data: {
          type: 'submissions',
          attributes: {
            task_id: task.id
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post "/v1/submissions?task_id=#{task.id}", params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      submission = Submission.first

      expect(json['data']).to have_id(submission.id)
      expect(json['data']).to have_attribute(:framework_id).with_value(framework.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data']).to have_attribute(:task_id).with_value(task.id)
    end
  end

  describe 'PATCH /submission/:submission_id' do
    it 'updates the given submission' do
      submission = FactoryBot.create(:submission)

      params = {
        data: {
          type: 'submissions',
          attributes: {
            levy: 42.50
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      patch "/v1/submissions/#{submission.id}", params: params.to_json, headers: headers

      expect(response).to have_http_status(:no_content)

      submission.reload

      expect(submission.levy).to eql 4250
      expect(submission).to be_in_review
    end
  end

  describe 'POST /submissions/:submission_id/files' do
    it 'creates a new submission file and returns its id' do
      submission = FactoryBot.create(:submission)

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post "/v1/submissions/#{submission.id}/files", params: {}, headers: headers

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

      params = {
        data: {
          type: 'submission_files',
          attributes: {
            rows: 1000
          }
        }
      }

      patch "/v1/submissions/#{submission.id}/files/#{file.id}", params: params.to_json, headers: headers

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

  describe 'GET /submissions/:submission_id/calculate' do
    it 'invokes the calculate lambda function successfully' do
      submission = FactoryBot.create(:submission)

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post "/v1/submissions/#{submission.id}/calculate", params: {}, headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /submissions/:submission_id/complete' do
    it 'marks the submission as complete' do
      task = FactoryBot.create(:task, status: :in_progress)

      submission = FactoryBot.create(
        :submission_with_validated_entries,
        aasm_state: :in_review,
        task: task
      )

      post "/v1/submissions/#{submission.id}/complete"

      expect(response).to be_successful

      submission.reload

      expect(submission).to be_completed
      expect(submission.task).to be_completed
    end
  end
end

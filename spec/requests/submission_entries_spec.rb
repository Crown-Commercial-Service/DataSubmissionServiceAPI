require 'rails_helper'

RSpec.describe '/v1' do
  let(:submission) { FactoryBot.create(:submission, framework: framework) }
  let(:framework) { FactoryBot.create(:framework, short_name: 'RM3756') }
  let(:valid_params) do
    {
      data: {
        type: 'submission_entries',
        attributes: {
          entry_type: 'invoice',
          source: {
            sheet: 'InvoicesRaised',
            row: 42
          },
          data: {
            'Total Cost (ex VAT)': 12.34
          }
        }
      }
    }
  end

  context 'scoped to a submission' do
    describe 'POST with valid params' do
      it 'creates a submission entry, extracting relevant data from the data hash and responds with JSON' do
        post "/v1/submissions/#{submission.id}/entries", params: valid_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        entry = SubmissionEntry.first
        expect(entry.total_value).to eq 12.34

        expect(json['data']).to have_id(entry.id)
        expect(json['data']).to have_attribute(:submission_id).with_value(submission.id)
        expect(json['data']).to have_attribute(:submission_file_id).with_value(nil)
        expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'InvoicesRaised'
        expect(json.dig('data', 'attributes', 'source', 'row')).to eql 42
        expect(json.dig('data', 'attributes', 'data', 'Total Cost (ex VAT)')).to eql 12.34
      end
    end

    describe 'POST when params are invalid' do
      let(:invalid_params) { valid_params.deep_merge(data: { attributes: { data: nil } }) }

      it 'responds with an error' do
        expect do
          post "/v1/submissions/#{submission.id}/entries", params: invalid_params.to_json, headers: json_headers
        end.to_not change { submission.entries.count }

        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST when an entry for the same row/sheet already exists' do
      let(:params_row_num) { valid_params[:data][:attributes][:source][:row] }

      before do
        FactoryBot.create(:invoice_entry, row: params_row_num, submission: submission, sheet_name: 'InvoicesRaised')
      end

      it 'does not add the entry and returns HTTP 204 No Content' do
        expect do
          post "/v1/submissions/#{submission.id}/entries", params: valid_params.to_json, headers: json_headers
        end.to_not change { submission.entries.count }

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  context 'scoped to a submission file' do
    let(:submission_file) { FactoryBot.create(:submission_file, submission_id: submission.id) }

    describe 'POST with valid params' do
      it 'creates a submission entry against the submission associated with the file and responds with JSON' do
        post "/v1/files/#{submission_file.id}/entries", params: valid_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        entry = SubmissionEntry.first
        expect(entry.total_value).to eq 12.34

        expect(json['data']).to have_id(entry.id)
        expect(json['data']).to have_attribute(:submission_id).with_value(submission.id)
        expect(json['data']).to have_attribute(:submission_file_id).with_value(submission_file.id)
        expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'InvoicesRaised'
        expect(json.dig('data', 'attributes', 'source', 'row')).to eql 42
        expect(json.dig('data', 'attributes', 'data', 'Total Cost (ex VAT)')).to eql 12.34
      end
    end

    describe 'PATCH against a pending submission entry' do
      let(:entry) { FactoryBot.create(:submission_entry, submission: submission, submission_file: submission_file) }
      let(:params) do
        {
          data: {
            type: 'submission_entries',
            attributes: {
              status: 'errored',
              validation_errors: [
                {
                  location: { row: 20, column: 2 },
                  message: 'Required value error'
                }
              ]
            }
          }
        }
      end

      it 'updates the submission entry attributes and triggers a submission status update' do
        status_update_double = double
        expect(status_update_double).to receive(:perform!)
        expect(SubmissionStatusUpdate).to receive(:new).with(submission).and_return(status_update_double)

        patch "/v1/files/#{submission_file.id}/entries/#{entry.id}", params: params.to_json, headers: json_headers

        expect(response).to have_http_status(:no_content)
        expect(entry.reload).to be_errored
        expect(entry.validation_errors[0]['message']).to eq 'Required value error'
        expect(entry.validation_errors[0]['location']).to eq('row' => 20, 'column' => 2)
      end
    end

    describe 'GET with an entry ID' do
      let(:submission_entry) do
        FactoryBot.create(
          :submission_entry,
          submission_id: submission.id,
          submission_file_id: submission_file.id,
          sheet_name: 'Orders',
          row: 23,
          data: { test: 'test' }
        )
      end

      it 'responds with JSON data for the entry' do
        get "/v1/files/#{submission_file.id}/entries/#{submission_entry.id}"

        expect(response).to have_http_status(:ok)

        expect(json['data']).to have_id(submission_entry.id)
        expect(json['data']).to have_attribute(:submission_id).with_value(submission.id)
        expect(json['data']).to have_attribute(:submission_file_id).with_value(submission_file.id)
        expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'Orders'
        expect(json.dig('data', 'attributes', 'source', 'row')).to eql 23
        expect(json.dig('data', 'attributes', 'data', 'test')).to eql 'test'
      end
    end
  end
end

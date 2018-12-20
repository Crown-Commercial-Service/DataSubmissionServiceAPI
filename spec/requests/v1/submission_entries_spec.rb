require 'rails_helper'

RSpec.describe '/v1' do
  let(:submission) { FactoryBot.create(:submission, framework: framework) }
  let(:framework) { FactoryBot.create(:framework, short_name: 'RM3756') }
  let(:customer) { FactoryBot.create(:customer) }
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
            'Total Cost (ex VAT)': 12.34,
            'Customer URN': customer.urn
          }
        }
      }
    }
  end
  let(:valid_bulk_params) do
    {
      data: [
        {
          type: 'submission_entries',
          attributes: {
            entry_type: 'invoice',
            source: {
              sheet: 'InvoicesRaised',
              row: 42
            },
            data: {
              'Total Cost (ex VAT)': 12.34,
              'Customer URN': customer.urn
            }
          }
        },
        {
          type: 'submission_entries',
          attributes: {
            entry_type: 'invoice',
            source: {
              sheet: 'InvoicesRaised',
              row: 43
            },
            data: {
              'Total Cost (ex VAT)': 12.35,
              'Customer URN': customer.urn
            }
          }
        }
      ]
    }
  end

  context 'scoped to a submission' do
    describe 'POST with valid params' do
      it 'creates a submission entry, extracting relevant data from the data hash and responds with JSON' do
        post "/v1/submissions/#{submission.id}/entries", params: valid_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        entry = SubmissionEntry.first
        expect(entry.total_value).to eq 12.34
        expect(entry.customer).to eq customer

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

    describe 'POST with a duff customer URN' do
      let(:invalid_urn_params) { valid_params.deep_merge(data: { attributes: { data: { 'Customer URN': '00000' } } }) }

      it 'still ingests the entry' do
        post "/v1/submissions/#{submission.id}/entries", params: invalid_urn_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        entry = SubmissionEntry.first
        expect(entry.total_value).to eq 12.34
        expect(entry.customer).to be_nil
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

    describe 'POST multiple valid entries' do
      it 'creates the submission entries, extracting relevant data from the data hash and responds with JSON' do
        post "/v1/submissions/#{submission.id}/entries/bulk", params: valid_bulk_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        expect(submission.entries.count).to eq 2

        entry = submission.entries.where(total_value: 12.35).first
        expect(entry.customer).to eq customer
      end
    end

    describe 'POST multiple entries with one invalid' do
      it 'creates valid submission entries, ignores invalid entries' do
        invalid_bulk_params = valid_bulk_params
        invalid_bulk_params[:data][1][:attributes][:data] = nil
        post "/v1/submissions/#{submission.id}/entries/bulk", params: invalid_bulk_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        expect(submission.entries.count).to eq 1
      end
    end

    describe 'POST multiple entries with one that already exists' do
      let(:params_row_num) { valid_bulk_params[:data][0][:attributes][:source][:row] }

      before do
        FactoryBot.create(:invoice_entry, row: params_row_num, submission: submission, sheet_name: 'InvoicesRaised')
      end

      it 'creates valid submission entries, ignores existing entries' do
        post "/v1/submissions/#{submission.id}/entries/bulk", params: valid_bulk_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)
        expect(submission.entries.count).to eq 2
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
        expect(entry.customer).to eq customer

        expect(json['data']).to have_id(entry.id)
        expect(json['data']).to have_attribute(:submission_id).with_value(submission.id)
        expect(json['data']).to have_attribute(:submission_file_id).with_value(submission_file.id)
        expect(json.dig('data', 'attributes', 'source', 'sheet')).to eql 'InvoicesRaised'
        expect(json.dig('data', 'attributes', 'source', 'row')).to eql 42
        expect(json.dig('data', 'attributes', 'data', 'Total Cost (ex VAT)')).to eql 12.34
      end
    end

    describe 'POST multiple valid entries' do
      it 'creates the submission entries, extracting relevant data from the data hash and responds with JSON' do
        post "/v1/files/#{submission_file.id}/entries/bulk", params: valid_bulk_params.to_json, headers: json_headers

        expect(response).to have_http_status(:created)

        expect(submission.entries.count).to eq 2

        entry = submission.entries.where(total_value: 12.35).first
        expect(entry.customer).to eq customer
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

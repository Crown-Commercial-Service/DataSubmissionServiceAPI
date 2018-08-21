# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /files/:file_id/blobs' do
    let(:submission_file) { FactoryBot.create(:submission_file) }
    let(:params) do
      {
        data: {
          type: 'file_blobs',
          attributes: {
            key: stubbed_blob_key,
            filename: 'filename.xlsx',
            content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            byte_size: 234936,
            checksum: 'r1gZERPTNkeuHwKyI9qUPQ=='
          }
        }
      }
    end

    it 'creates the file attachment against the submission file' do
      post v1_file_blobs_path(submission_file.id), params: params.to_json, headers: json_headers

      expect(response).to have_http_status(:created)
      expect(json['data']).to have_id(submission_file.id)

      file_attachment = submission_file.file

      expect(file_attachment).to be_attached
      expect(file_attachment.key).to eq(stubbed_blob_key)
      expect(file_attachment.filename).to eq('filename.xlsx')
      expect(file_attachment.content_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      expect(file_attachment.byte_size).to eq(234936)
      expect(file_attachment.checksum).to eq('r1gZERPTNkeuHwKyI9qUPQ==')
    end
  end
end

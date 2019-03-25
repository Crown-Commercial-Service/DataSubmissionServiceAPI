require 'rails_helper'

RSpec.describe Export::S3Upload do
  let(:files_map) { { 'file1.csv' => file_1, 'file2.json' => file_2 } }
  let(:file_1) { File.open(Rails.root.join('spec', 'fixtures', 'users.csv')) }
  let(:file_2) { File.open(Rails.root.join('spec', 'fixtures', 'bank_holidays.json')) }

  subject(:s3_upload) { Export::S3Upload.new(files_map) }

  around do |example|
    ClimateControl.modify AWS_S3_EXPORT_BUCKET: 'test-bucket' do
      example.run
    end
  end

  describe '#perform' do
    it 'uploads each file to the configured S3 bucket' do
      s3_upload.perform

      expect(s3_upload.client.api_requests.size).to eq(2)

      first_request, second_request = s3_upload.client.api_requests

      expect(first_request[:operation_name]).to eq(:put_object)
      expect(first_request[:params][:key]).to eq('file1.csv')
      expect(first_request[:params][:body]).to eq(file_1)
      expect(first_request[:params][:bucket]).to eq('test-bucket')

      expect(second_request[:operation_name]).to eq(:put_object)
      expect(second_request[:params][:key]).to eq('file2.json')
      expect(second_request[:params][:body]).to eq(file_2)
      expect(second_request[:params][:bucket]).to eq('test-bucket')
    end
  end
end

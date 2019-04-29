require 'rails_helper'

RSpec.describe Export::AzureUpload do
  let(:files_map) { { 'file1.csv' => file_1, 'file2.json' => file_2 } }
  let(:file_1) { File.open(Rails.root.join('spec', 'fixtures', 'users.csv')) }
  let(:file_2) { File.open(Rails.root.join('spec', 'fixtures', 'bank_holidays.json')) }

  subject(:azure_upload) { Export::AzureUpload.new(files_map) }

  let(:blob_client) { spy('blob_client') }

  around do |example|
    ClimateControl.modify AZURE_CONTAINER_NAME: 'test-container' do
      example.run
    end
  end

  describe '#perform' do
    it 'uploads each file to the configured Azure container' do
      allow(azure_upload).to receive(:client).and_return(blob_client)
      azure_upload.perform

      expect(blob_client).to have_received(:create_block_blob).with(
        'test-container',
        'file1.csv',
        file_1.read
      ).once

      expect(blob_client).to have_received(:create_block_blob).with(
        'test-container',
        'file2.json',
        file_2.read
      ).once
    end
  end
end

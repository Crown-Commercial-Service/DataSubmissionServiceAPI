require 'rails_helper'
require 'digest'

RSpec.describe AttachedFileDownloader do
  around do |example|
    ClimateControl.modify AWS_S3_BUCKET: 'fake', AWS_S3_REGION: 'zz-north-1' do
      example.run
    end
  end

  describe '#download!' do
    let(:urn_list) { create(:urn_list, filename: 'customers.xlsx') }

    it 'downloads the file from S3' do
      stub_s3_get_object('customers.xlsx')

      original_file_path = Rails.root.join('spec', 'fixtures', 'customers.xlsx')

      downloader = AttachedFileDownloader.new(urn_list.excel_file)
      downloader.download!

      path = downloader.temp_file.path

      expect(path).to include 'UrnList'
      expect(path).to end_with '.xlsx'

      expect(File.exist?(path)).to be_truthy
      expect(Digest::MD5.file(path)).to eq Digest::MD5.file(original_file_path)
    end

    it 'throws an error when the file does not exist' do
      stub_s3_get_object_with_exception('NotFound')

      downloader = AttachedFileDownloader.new(urn_list.excel_file)

      expect { downloader.download! }.to raise_error(Aws::S3::Errors::NotFound)
    end

    it 'throws an error when AWS times out' do
      stub_s3_get_object_with_exception(Timeout::Error)

      downloader = AttachedFileDownloader.new(urn_list.excel_file)

      expect { downloader.download! }.to raise_error(Timeout::Error)
    end
  end

  describe '#cleanup!' do
    let(:submission_file) { create(:submission_file, :with_attachment, filename: 'customers.xlsx') }

    it 'deletes the temporary file' do
      stub_s3_get_object('customers.xlsx')

      downloader = AttachedFileDownloader.new(submission_file.file)
      downloader.download!
      temp_path = downloader.temp_file.path

      expect { downloader.cleanup! }.to change { File.exist?(temp_path) }.from(true).to(false)
    end
  end
end

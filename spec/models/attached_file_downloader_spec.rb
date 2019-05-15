require 'rails_helper'
require 'digest'

RSpec.describe AttachedFileDownloader do
  describe '#download!' do
    let(:urn_list_id) { 'f27fa106-e4a8-445a-8082-ed512a945a92' }
    let(:urn_list) { create(:urn_list, filename: 'customers.xlsx', id: urn_list_id) }

    it 'downloads the file from S3' do
      original_file_path = Rails.root.join('spec', 'fixtures', 'customers.xlsx')

      downloader = AttachedFileDownloader.new(urn_list.excel_file)
      downloader.download!

      path = downloader.temp_file.path

      expect(path).to include 'UrnList'
      expect(path).to end_with '.xlsx'

      expect(File.exist?(path)).to be_truthy
      expect(Digest::MD5.file(path)).to eq Digest::MD5.file(original_file_path)

      downloader.temp_file.close
      downloader.temp_file.unlink

      expect(File.exist?(path)).to be_falsy
    end
  end
end

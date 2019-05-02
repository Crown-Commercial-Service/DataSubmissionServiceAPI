require 'rails_helper'

RSpec.describe Ingest::SubmissionFileDownloader do
  let(:file_id) { 'ca52d38f-00b2-457a-888c-14a878f29897' }
  let(:file) { create(:submission_file, :with_attachment, filename: 'test.xls', id: file_id) }

  subject(:downloader) { Ingest::SubmissionFileDownloader.new(file) }

  describe '.downloaded?' do
    it "is true when the submission's file was successfully downloaded" do
      result = downloader.perform

      expect(result).to be_downloaded
    end

    it "is false if the submission's file was not downloaded" do
      allow(file.file.blob).to receive(:download).and_raise(Aws::S3::Errors::ServiceError)

      result = downloader.perform

      expect(result).to_not be_downloaded
    end
  end

  describe '.temp_file' do
    context 'with an XLS file' do
      it 'returns the full path to the downloaded file, with the correct extension' do
        expect(downloader.perform.temp_file).to eql '/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xls'
      end
    end

    context 'with an XLSX file' do
      let(:file) { create(:submission_file, :with_attachment, filename: 'test.xlsx', id: file_id) }

      it 'returns the full path to the downloaded file, with the correct extension' do
        expect(downloader.perform.temp_file).to eql '/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xlsx'
      end
    end

    context 'with a file whose extension is uppercase' do
      let(:file) { create(:submission_file, :with_attachment, filename: 'uppercase.XLS', id: file_id) }

      it 'returns downcases the extension of the temporary file' do
        expect(downloader.perform.temp_file).to eql '/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xls'
      end
    end
  end
end

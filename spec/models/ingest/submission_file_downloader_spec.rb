require 'rails_helper'

RSpec.describe Ingest::SubmissionFileDownloader do
  let(:file_id) { 'ca52d38f-00b2-457a-888c-14a878f29897' }
  let(:file) { create(:submission_file, :with_attachment, filename: 'test.xls', id: file_id) }

  subject(:downloader) { Ingest::SubmissionFileDownloader.new(file) }

  describe '.completed?' do
    let(:thread) { double('thread') }
    let(:thread_value) { double('thread_value') }

    it "is true when the submission's file was successfully downloaded" do
      allow(thread_value).to receive(:success?).and_return(true)
      allow(thread).to receive(:value).and_return(thread_value)
      allow(Open3).to receive(:popen3).with(/curl/).and_yield(nil, [], [], thread)
      allow(File).to receive(:exist?).with('/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xls').and_return(true)

      downloader.perform

      expect(downloader.completed?).to be_truthy
    end

    it "is false if the submission's file was not downloaded" do
      allow(thread_value).to receive(:success?).and_return(true)
      allow(thread).to receive(:value).and_return(thread_value)
      allow(Open3).to receive(:popen3).with(/curl/).and_yield(nil, [], [], thread)
      allow(File).to receive(:exist?).with('/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xls').and_return(false)

      downloader.perform

      expect(downloader.completed?).to be_falsy
    end

    it 'is false if a non-zero exit code was received' do
      allow(thread_value).to receive(:success?).and_return(false)
      allow(thread).to receive(:value).and_return(thread_value)
      allow(Open3).to receive(:popen3).with(/curl/).and_yield(nil, [], [], thread)
      allow(File).to receive(:exist?).with('/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xls').and_return(false)

      downloader.perform

      expect(downloader.completed?).to be_falsy
    end

    it 'is false before the download has started' do
      expect(downloader.completed?).to be_falsy
    end
  end

  describe '.temp_file' do
    context 'with an XLS file' do
      it 'returns the full path to the downloaded file, with the correct extension' do
        expect(downloader.temp_file).to eql '/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xls'
      end
    end

    context 'with an XLSX file' do
      let(:file) { create(:submission_file, :with_attachment, filename: 'test.xlsx', id: file_id) }

      it 'returns the full path to the downloaded file, with the correct extension' do
        expect(downloader.temp_file).to eql '/tmp/ca52d38f-00b2-457a-888c-14a878f29897.xlsx'
      end
    end
  end

  describe '.submission_file' do
    it 'returns to SubmissionFile that was downloaded' do
      expect(downloader.submission_file).to eql(file)
    end
  end
end

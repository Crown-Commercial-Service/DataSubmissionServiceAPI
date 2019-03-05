require 'rails_helper'

RSpec.describe SubmissionFile do
  it { is_expected.to belong_to(:submission) }
  it { is_expected.to have_many(:entries) }

  describe '#filename' do
    it 'returns the filename of the attachment' do
      submission_file = FactoryBot.create(:submission_file, :with_attachment)

      expect(submission_file.filename).to eq 'not-really-an.xls'
    end

    it 'returns nil if no file attachment exists' do
      expect(SubmissionFile.new.filename).to be_nil
    end
  end

  describe '#temporary_download_url' do
    it 'returns the temporary download URL of the attachment' do
      submission_file = FactoryBot.create(:submission_file, :with_attachment, filename: 'not-really-an.xls')

      expect(submission_file.temporary_download_url)
        .to start_with('http://s3.example.com')
        .and end_with('not-really-an.xls')
    end

    it 'returns nil if no file attachment exists' do
      expect(SubmissionFile.new.temporary_download_url).to be_nil
    end
  end
end

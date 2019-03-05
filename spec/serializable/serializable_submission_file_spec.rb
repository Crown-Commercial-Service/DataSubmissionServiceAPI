require 'rails_helper'

RSpec.describe SerializableSubmissionFile do
  context 'given a submission file with an attachment' do
    let(:submission_file) { FactoryBot.create(:submission_file, :with_attachment, filename: 'not-really-an.xls') }
    let(:serialized_submission_file) { SerializableSubmissionFile.new(object: submission_file) }

    it 'exposes the filename of the attached file' do
      expect(serialized_submission_file.as_jsonapi[:attributes][:filename]).to eql 'not-really-an.xls'
    end

    it 'exposes the temporary download URL of the attached file' do
      expect(serialized_submission_file.as_jsonapi[:attributes][:temporary_download_url])
        .to start_with('http://s3.example.com')
        .and end_with('not-really-an.xls')
    end
  end
end

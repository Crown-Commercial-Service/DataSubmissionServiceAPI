require 'rails_helper'

RSpec.describe SerializableSubmissionFile do
  let(:submission_file) { FactoryBot.create(:submission_file, :with_attachment, filename: 'not-really-an.xls') }
  let(:serialized_submission_file) { SerializableSubmissionFile.new(object: submission_file) }

  it 'exposes the filename of the uploaded file' do
    expect(serialized_submission_file.as_jsonapi[:attributes][:filename]).to eq('not-really-an.xls')
  end
end

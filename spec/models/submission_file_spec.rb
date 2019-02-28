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
end

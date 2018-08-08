require 'rails_helper'

RSpec.describe SubmissionEntry do
  it { is_expected.to belong_to(:submission) }
  it { is_expected.to belong_to(:submission_file) }

  it { is_expected.to validate_presence_of(:data) }

  describe 'sheet scope' do
    let(:sheet_1_entry) { FactoryBot.create(:submission_entry, source: { 'sheet' => 'Sheet 1' }) }
    let(:another_sheet_1_entry) { FactoryBot.create(:submission_entry, source: { 'sheet' => 'Sheet 1' }) }
    let(:sheet_2_entry) { FactoryBot.create(:submission_entry, source: { 'sheet' => 'Sheet 2' }) }

    it 'returns entries for the specified sheet' do
      expect(SubmissionEntry.sheet('Sheet 1')).to contain_exactly(sheet_1_entry, another_sheet_1_entry)
      expect(SubmissionEntry.sheet('Sheet 2')).to contain_exactly(sheet_2_entry)
    end
  end
end

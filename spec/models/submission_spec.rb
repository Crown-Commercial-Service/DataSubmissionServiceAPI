require 'rails_helper'

RSpec.describe Submission do
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:task) }

  it { is_expected.to have_many(:files) }
  it { is_expected.to have_many(:entries) }

  describe '#ready_for_review state machine event' do
    it 'transitions from processing to in_review, with a valid submission' do
      submission = FactoryBot.create(:submission_with_validated_entries, aasm_state: :processing)
      submission.ready_for_review

      expect(submission).to be_in_review
    end

    it 'transitions from processing to validation_failed, when there are errors' do
      submission = FactoryBot.create(:submission_with_invalid_entries, aasm_state: :processing)
      submission.ready_for_review

      expect(submission).to be_validation_failed
    end
  end

  describe '#sheet_names' do
    let(:submission) { FactoryBot.create(:submission) }
    let!(:invoice) { FactoryBot.create(:submission_entry, submission: submission, sheet_name: 'Invoices') }
    let!(:order) { FactoryBot.create(:submission_entry, submission: submission, sheet_name: 'Orders') }

    it 'returns the sheets that the submission has entries for' do
      expect(submission.sheet_names).to match_array %w[Invoices Orders]
    end
  end

  describe '#report_no_business?' do
    it 'returns false if submission has files' do
      expect(FactoryBot.create(:submission_with_validated_entries).report_no_business?).to be(false)
    end
    it 'returns true if submission has no files' do
      expect(FactoryBot.create(:submission).report_no_business?).to be(true)
    end
  end
end

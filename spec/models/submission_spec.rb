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

  describe 'sums on invoice entries' do
    let(:submission) do
      FactoryBot.create(:submission).tap do |submission|
        submission.entries << FactoryBot.build(:invoice_entry, :valid, total_value: 100.00, management_charge: 1)
        submission.entries << FactoryBot.build(:invoice_entry, :valid, total_value: 460.00, management_charge: 4.6)
        submission.entries << FactoryBot.build(:order_entry, :valid, total_value: 99.00)
      end
    end

    describe '#management_charge' do
      it 'returns the sum of all the management charges for the entries of type "invoice"' do
        expect(submission.management_charge).to eq BigDecimal('5.60')
      end
    end

    describe '#total_spend' do
      it 'returns the sum of all the total_values for the entries of type "invoice"' do
        expect(submission.total_spend).to eq BigDecimal('560')
      end
    end
  end
end

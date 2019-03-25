require 'rails_helper'

RSpec.describe Submission do
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:created_by) }
  it { is_expected.to belong_to(:submitted_by) }
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

  describe '#replace_with_no_business state machine event' do
    let(:submission) { FactoryBot.create(:completed_submission) }

    it 'transitions from completed to replaced' do
      submission.replace_with_no_business

      expect(submission).to be_replaced
    end

    context 'when SUBMIT_INVOICES env flag is set' do
      around do |example|
        ClimateControl.modify SUBMIT_INVOICES: 'true' do
          example.run
        end
      end

      context 'when there is an invoice for the submission' do
        let!(:invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

        it 'enqueues the creation of a reversal invoice' do
          submission.replace_with_no_business

          expect(SubmissionReversalInvoiceCreationJob).to have_been_enqueued
        end
      end

      context 'when there is no invoice for the submission' do
        it 'does not enqueue the creation of a reversal invoice' do
          submission.replace_with_no_business

          expect(SubmissionReversalInvoiceCreationJob).to_not have_been_enqueued
        end
      end
    end

    context 'when SUBMIT_INVOICES env flag is not set' do
      around do |example|
        ClimateControl.modify SUBMIT_INVOICES: nil do
          example.run
        end
      end

      context 'when there is an invoice for the submission' do
        let!(:invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

        it 'does not enqueue the creation of a reversal invoice' do
          submission.replace_with_no_business

          expect(SubmissionReversalInvoiceCreationJob).to_not have_been_enqueued
        end
      end
    end
  end

  describe '#mark_as_replaced state machine event' do
    let(:submission) { FactoryBot.create(:completed_submission) }

    it 'transitions from completed to replaced' do
      submission.mark_as_replaced

      expect(submission).to be_replaced
    end

    context 'when SUBMIT_INVOICES env flag is set' do
      around do |example|
        ClimateControl.modify SUBMIT_INVOICES: 'true' do
          example.run
        end
      end

      context 'when there is an invoice for the submission' do
        let!(:invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

        it 'enqueues the creation of a reversal invoice' do
          submission.mark_as_replaced

          expect(SubmissionReversalInvoiceCreationJob).to have_been_enqueued
        end
      end

      context 'when there is no invoice for the submission' do
        it 'does not enqueue the creation of a reversal invoice' do
          submission.mark_as_replaced

          expect(SubmissionReversalInvoiceCreationJob).to_not have_been_enqueued
        end
      end
    end

    context 'when SUBMIT_INVOICES env flag is not set' do
      around do |example|
        ClimateControl.modify SUBMIT_INVOICES: nil do
          example.run
        end
      end

      context 'when there is an invoice for the submission' do
        let!(:invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

        it 'does not enqueue the creation of a reversal invoice' do
          submission.mark_as_replaced

          expect(SubmissionReversalInvoiceCreationJob).to_not have_been_enqueued
        end
      end
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
        submission.entries << FactoryBot.build(:order_entry, :valid, total_value: 3.40)
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

    describe '#order_total_value' do
      it 'returns the sum of all the total_values for the entries of type "order"' do
        expect(submission.order_total_value).to eq BigDecimal('102.4')
      end
    end
  end

  describe '#sheet_errors' do
    let(:submission) { FactoryBot.create(:submission) }
    let!(:errored_invoice) do
      FactoryBot.create(
        :invoice_entry,
        :errored,
        column: 'Total',
        row: 1,
        error_message: 'missing value',
        submission: submission
      )
    end
    let!(:errored_order) do
      FactoryBot.create(
        :order_entry,
        :errored,
        column: 'Total',
        row: 1,
        error_message: 'not a number',
        submission: submission
      )
    end
    let!(:errored_order_2) do
      FactoryBot.create(
        :order_entry,
        :errored,
        column: 'URN',
        row: 2,
        error_message: 'missing value',
        submission: submission
      )
    end

    it 'returns the entry validation errors, grouped by their sheet name' do
      expect(submission.sheet_errors).to eq(
        'InvoicesRaised' => [
          { 'message' => 'missing value', 'location' => { 'row' => 1, 'column' => 'Total' } }
        ],
        'OrdersReceived' => [
          { 'message' => 'not a number', 'location' => { 'row' => 1, 'column' => 'Total' } },
          { 'message' => 'missing value', 'location' => { 'row' => 2, 'column' => 'URN' } }
        ]
      )
    end
  end
end

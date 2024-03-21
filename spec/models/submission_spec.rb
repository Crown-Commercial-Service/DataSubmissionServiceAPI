require 'rails_helper'

RSpec.describe Submission do
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:created_by).optional }
  it { is_expected.to belong_to(:submitted_by).optional }
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
    let(:submission_with_no_invoice) do
      FactoryBot.create(:submission_with_zero_management_charge, aasm_state: 'completed')
    end
    let(:correcting_user) { FactoryBot.create(:user) }

    it 'transitions from completed to replaced' do
      submission.replace_with_no_business(correcting_user)

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

        it 'enqueues the creation of a reversal invoice with the correct arguments' do
          allow(SubmissionReversalInvoiceCreationJob).to receive(:perform_later)

          submission.replace_with_no_business(correcting_user)

          expect(SubmissionReversalInvoiceCreationJob).to have_received(:perform_later)
            .with(submission, correcting_user)
        end
      end

      context 'when there is no invoice for the submission' do
        it 'does not enqueue the creation of a reversal invoice' do
          submission_with_no_invoice.replace_with_no_business(correcting_user)

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

      context 'when there should be an invoice for the original submission' do
        it 'does not enqueue the creation of a reversal invoice' do
          submission.replace_with_no_business(correcting_user)

          expect(SubmissionReversalInvoiceCreationJob).to_not have_been_enqueued
        end
      end
    end
  end

  describe '#mark_as_replaced state machine event' do
    let(:submission) { FactoryBot.create(:completed_submission) }
    let(:submission_with_no_invoice) do
      FactoryBot.create(:submission_with_zero_management_charge, aasm_state: 'completed')
    end
    let(:correcting_user) { FactoryBot.create(:user) }

    it 'transitions from completed to replaced' do
      submission.mark_as_replaced(correcting_user)

      expect(submission).to be_replaced
    end

    context 'when SUBMIT_INVOICES env flag is set' do
      around do |example|
        ClimateControl.modify SUBMIT_INVOICES: 'true' do
          example.run
        end
      end

      context 'when there should be an invoice for the original submission' do
        it 'enqueues the creation of a reversal invoice with the correct arguments' do
          allow(SubmissionReversalInvoiceCreationJob).to receive(:perform_later)

          submission.mark_as_replaced(correcting_user)

          expect(SubmissionReversalInvoiceCreationJob).to have_received(:perform_later)
            .with(submission, correcting_user)
        end
      end

      context 'when there should be no invoice for the original submission' do
        it 'does not enqueue the creation of a reversal invoice' do
          submission_with_no_invoice.mark_as_replaced(correcting_user)

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
          submission.mark_as_replaced(correcting_user)

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
      context 'a submission that already has its management_charge_total calculated' do
        before do
          allow(submission).to receive(:management_charge_total).and_return(BigDecimal('0.7'))
        end

        it 'returns the value in the management_charge_total column' do
          expect(submission.management_charge).to eq BigDecimal('0.7')
        end
      end

      context 'a submission whose management_charge is nil' do
        it 'returns the sum of all the management charges for the entries of type "invoice"' do
          expect(submission.management_charge).to eq BigDecimal('5.60')
        end
      end
    end

    describe '#total_spend' do
      context 'there is a backfilled invoice_total value for performance' do
        before { submission.invoice_total = BigDecimal('999') }
        it 'returns that value in preference' do
          expect(submission.total_spend).to eq BigDecimal('999')
        end
      end

      context 'there is no backfilled invoice_total value' do
        before { submission.invoice_total = nil }
        it 'returns the sum of all the total_values for the entries of type "invoice"' do
          expect(submission.total_spend).to eq BigDecimal('560')
        end
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

  describe '#file_key' do
    context 'when file exists' do
      it 'returns the file key' do
        submission = FactoryBot.create(:completed_submission)
        expect(submission.file_key).to eq(submission.files.first.file.attachment.key)
      end
    end

    context 'when file does not exist' do
      it 'returns nil' do
        submission = FactoryBot.create(:no_business_submission)
        expect(submission.file_key).to eq(nil)
      end
    end
  end

  describe '#filename' do
    context 'when file exists' do
      it 'returns the file name' do
        submission = FactoryBot.create(:completed_submission)
        expect(submission.filename).to eq(submission.files.first.file.attachment.filename.to_s)
      end
    end

    context 'when file does not exist' do
      it 'returns nil' do
        submission = FactoryBot.create(:no_business_submission)
        expect(submission.filename).to eq(nil)
      end
    end
  end

  describe '#invoice_details' do
    context 'when submission invoice exists' do
      let(:submission) { FactoryBot.create(:completed_submission) }
      let!(:submission_invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

      it 'returns invoice number, amount and status' do
        invoice_details_double = double(invoice_details: 'Invoice details')
        allow(Workday::CustomerInvoice).to receive(:new)
          .with(submission_invoice.workday_reference).and_return(invoice_details_double)

        expect(submission.invoice_details).to eq('Invoice details')
      end
    end

    context 'when there is a Workday connection error' do
      let(:submission) { FactoryBot.create(:completed_submission) }
      let!(:submission_invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

      it 'returns nil' do
        allow(Workday::CustomerInvoice).to receive(:new)
          .with(submission_invoice.workday_reference).and_raise(Workday::ConnectionError)

        expect(submission.invoice_details).to eq(nil)
      end
    end
  end

  describe '#credit_note_details' do
    context 'when submission reversal invoice exists' do
      let(:submission) { FactoryBot.create(:completed_submission) }
      let!(:submission_invoice) { FactoryBot.create(:submission_invoice, submission: submission, reversal: true) }

      it 'returns invoice number, amount and status' do
        invoice_details_double = double(invoice_details: 'Invoice details')
        allow(Workday::CustomerInvoice).to receive(:new)
          .with(submission_invoice.workday_reference).and_return(invoice_details_double)

        expect(submission.credit_note_details).to eq('Invoice details')
      end
    end
  end
end

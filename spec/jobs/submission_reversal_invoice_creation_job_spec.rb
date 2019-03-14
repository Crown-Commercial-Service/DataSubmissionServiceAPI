require 'rails_helper'

RSpec.describe SubmissionReversalInvoiceCreationJob do
  describe '#perform' do
    context 'given a submission that has a positive management_charge' do
      let!(:submission) { FactoryBot.create(:submission_with_positive_management_charge) }
      let!(:submission_invoice) { FactoryBot.create(:submission_invoice, submission: submission) }
      let(:submit_reversal_invoice_adjustment_double) { double(perform: 'INVOICE_ID') }
      before do
        allow(Workday::SubmitReversalInvoiceAdjustment).to receive(:new)
          .with(submission).and_return(submit_reversal_invoice_adjustment_double)
      end

      it 'calls SubmitReversalInvoiceAdjustment with correct submission' do
        SubmissionReversalInvoiceCreationJob.perform_now(submission)

        expect(submit_reversal_invoice_adjustment_double).to have_received(:perform)
      end

      it 'creates a SubmissionInvoice with the correct workday_reference' do
        expect do
          SubmissionReversalInvoiceCreationJob.perform_now(submission)
        end.to change { SubmissionInvoice.count }.by(1)
        expect(submission.reversal_invoice.workday_reference).to eq('INVOICE_ID')
      end

      it 'does not overwrite the existing invoice' do
        SubmissionReversalInvoiceCreationJob.perform_now(submission)
        expect(submission.invoice).to eq(submission_invoice)
      end

      it 'raise if a reversal invoice already exists' do
        submission.reversal_invoice = FactoryBot.create(:submission_invoice)
        expect do
          SubmissionReversalInvoiceCreationJob.perform_now(submission)
        end.to raise_error(/already has a reversal invoice/)
        expect(submit_reversal_invoice_adjustment_double).to_not have_received(:perform)
      end
    end

    context 'given a submission that has a negative management_charge' do
      let(:submission) { FactoryBot.create(:submission_with_negative_management_charge) }
      let(:submit_reversal_invoice_double) { double(perform: 'INVOICE_ID') }
      before do
        allow(Workday::SubmitReversalInvoice).to receive(:new)
          .with(submission).and_return(submit_reversal_invoice_double)
      end

      it 'calls SubmitReversalInvoice with correct submission' do
        SubmissionReversalInvoiceCreationJob.perform_now(submission)

        expect(submit_reversal_invoice_double).to have_received(:perform)
      end

      it 'creates a SubmissionInvoice with the correct workday_reference' do
        expect do
          SubmissionReversalInvoiceCreationJob.perform_now(submission)
        end.to change { SubmissionInvoice.count }.by(1)
        expect(submission.reversal_invoice.workday_reference).to eq('INVOICE_ID')
      end
    end
  end
end

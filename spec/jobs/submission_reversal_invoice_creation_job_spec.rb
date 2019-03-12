require 'rails_helper'

RSpec.describe SubmissionReversalInvoiceCreationJob do
  describe '#perform' do
    context 'with a positive management_charge' do
      let(:submission) { FactoryBot.create(:submission_with_positive_management_charge) }
      let(:submit_reversal_invoice_adjustment_request_double) { double(perform: 'INVOICE_ID') }
      before do
        allow(Workday::SubmitReversalCustomerInvoiceAdjustmentRequest).to receive(:new)
          .with(submission).and_return(submit_reversal_invoice_adjustment_request_double)
      end

      it 'calls SubmitReversalCustomerInvoiceAdjustmentRequest with correct submission' do
        SubmissionReversalInvoiceCreationJob.perform_now(submission)

        expect(submit_reversal_invoice_adjustment_request_double).to have_received(:perform)
      end

      it 'creates a SubmissionInvoice with the correct workday_reference' do
        expect do
          SubmissionReversalInvoiceCreationJob.perform_now(submission)
        end.to change { SubmissionInvoice.count }.by(1)
        expect(submission.reversal_invoice.workday_reference).to eq('INVOICE_ID')
      end

      it 'raise if a reversal invoice already exists' do
        submission.reversal_invoice = FactoryBot.create(:submission_invoice)
        expect do
          SubmissionReversalInvoiceCreationJob.perform_now(submission)
        end.to raise_error(/already has a reversal invoice/)
        expect(submit_reversal_invoice_adjustment_request_double).to_not have_received(:perform)
      end
    end

    context 'with a negative management_charge' do
      let(:submission) { FactoryBot.create(:submission_with_negative_management_charge) }
      let(:submit_reversal_invoice_request_double) { double(perform: 'INVOICE_ID') }
      before do
        allow(Workday::SubmitReversalCustomerInvoiceRequest).to receive(:new)
          .with(submission).and_return(submit_reversal_invoice_request_double)
      end

      it 'calls SubmitReversalCustomerInvoiceRequest with correct submission' do
        SubmissionReversalInvoiceCreationJob.perform_now(submission)

        expect(submit_reversal_invoice_request_double).to have_received(:perform)
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

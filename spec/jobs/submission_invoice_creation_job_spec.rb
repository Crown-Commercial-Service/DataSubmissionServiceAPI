require 'rails_helper'

RSpec.describe SubmissionInvoiceCreationJob do
  describe '#perform' do
    context 'with a positive management_charge' do
      let(:submission) { FactoryBot.create(:submission_with_positive_management_charge) }
      let(:submit_invoice_request_double) { double(perform: 'INVOICE_ID') }
      before do
        allow(Workday::SubmitCustomerInvoiceRequest).to receive(:new)
          .with(submission).and_return(submit_invoice_request_double)
      end

      it 'calls SubmitCustomerInvoiceRequest with correct submission' do
        SubmissionInvoiceCreationJob.perform_now(submission)

        expect(submit_invoice_request_double).to have_received(:perform)
      end

      it 'creates a SubmissionInvoice with the correct workday_reference' do
        expect do
          SubmissionInvoiceCreationJob.perform_now(submission)
        end.to change { SubmissionInvoice.count }.by(1)
        expect(submission.invoice.workday_reference).to eq('INVOICE_ID')
      end

      it 'raise if an invoice already exists' do
        submission.invoice = FactoryBot.create(:submission_invoice)
        expect do
          SubmissionInvoiceCreationJob.perform_now(submission)
        end.to raise_error(/already has an invoice/)
        expect(submit_invoice_request_double).to_not have_received(:perform)
      end
    end

    context 'with a negative management_charge' do
      let(:submission) { FactoryBot.create(:submission_with_negative_management_charge) }
      let(:submit_invoice_request_adjustment_double) { double(perform: 'INVOICE_ID') }
      before do
        allow(Workday::SubmitCustomerInvoiceAdjustmentRequest).to receive(:new)
          .with(submission).and_return(submit_invoice_request_adjustment_double)
      end

      it 'calls SubmitCustomerInvoiceAdjustmentRequest with correct submission' do
        SubmissionInvoiceCreationJob.perform_now(submission)

        expect(submit_invoice_request_adjustment_double).to have_received(:perform)
      end

      it 'creates a SubmissionInvoice with the correct workday_reference' do
        expect do
          SubmissionInvoiceCreationJob.perform_now(submission)
        end.to change { SubmissionInvoice.count }.by(1)
        expect(submission.invoice.workday_reference).to eq('INVOICE_ID')
      end
    end
  end
end

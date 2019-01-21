require 'rails_helper'

RSpec.describe SubmissionInvoiceCreationJob do
  describe '#perform' do
    let(:submission) { FactoryBot.create(:submission) }
    let(:submit_invoice_request_double) { double(perform: 'INVOICE_ID') }
    before do
      allow(Workday::SubmitCustomerInvoiceRequest).to receive(:new)
        .with(submission).and_return(submit_invoice_request_double)
    end

    it 'calls SubmitCustomerInvoiceRequest with correct submission' do
      SubmissionInvoiceCreationJob.perform_now(submission)

      expect(submit_invoice_request_double).to have_received(:perform)
    end
  end
end

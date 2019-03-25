require 'rails_helper'

RSpec.describe SerializableSubmission do
  context 'given a submission with invoices and orders' do
    let(:submission) { FactoryBot.create(:submission, invoice_entries: 2, order_entries: 3) }
    let(:serialized_submission) { SerializableSubmission.new(object: submission) }

    it 'exposes a count of the number of invoice entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:invoice_count]).to eq(2)
    end

    it 'exposes a count of the number of order entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:order_count]).to eq(3)
    end

    it 'exposes the total value of invoice entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:invoice_total_value]).to eq(0.0)
    end

    it 'exposes the total value of order entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:order_total_value]).to eq(0.0)
    end

    it 'exposes a report_no_business? boolean' do
      expect(serialized_submission.as_jsonapi[:attributes][:report_no_business?]).to eq(true)
    end

    it 'exposes a sheet_errors hash' do
      expect(serialized_submission.as_jsonapi[:attributes][:sheet_errors]).to eq(
        'InvoicesRaised' => [], 'OrdersReceived' => []
      )
    end
  end
end

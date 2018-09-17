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
  end
end

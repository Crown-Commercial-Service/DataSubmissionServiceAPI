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

    let(:serialized_submission) { SerializableSubmission.new(object: submission) }

    it 'returns the entry validation errors, grouped by their sheet name' do
      expect(serialized_submission.as_jsonapi[:attributes][:sheet_errors]).to eq(
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

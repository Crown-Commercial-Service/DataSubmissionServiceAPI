require 'rails_helper'

RSpec.describe SerializableSubmission do
  context 'given a submission with invoices, orders and others' do
    let(:user) { FactoryBot.create(:user) }
    let(:submission) do
      FactoryBot.create(:completed_submission, submitted_by: user) do |submission|
        FactoryBot.create(:other_entry, submission: submission)
      end
    end

    let(:serialized_submission) { SerializableSubmission.new(object: submission) }

    it 'exposes a count of the number of invoice entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:invoice_count]).to eq(2)
    end

    it 'exposes a count of the number of order entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:order_count]).to eq(1)
    end

    it 'exposes a count of the number of other entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:other_count]).to eq(1)
    end

    it 'exposes the total value of invoice entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:invoice_total_value]).to eq(20)
    end

    it 'exposes the total value of order entries' do
      expect(serialized_submission.as_jsonapi[:attributes][:order_total_value]).to eq(3)
    end

    it 'exposes a report_no_business? boolean' do
      expect(serialized_submission.as_jsonapi[:attributes][:report_no_business?]).to eq(false)
    end

    it 'exposes a sheet_errors hash' do
      expect(serialized_submission.as_jsonapi[:attributes][:sheet_errors]).to eq(
        'InvoicesRaised' => [],
        'OrdersReceived' => [],
        'Bid Invitations' => []
      )
    end

    it 'exposes associated submitted_by user details' do
      expect(serialized_submission.as_jsonapi[:attributes][:submitter]).to eq(user)
    end

    it 'exposes the submissions file key' do
      expect(serialized_submission.as_jsonapi[:attributes][:file_key]).to eq(submission.file_key)
    end

    it 'exposes the submissions file name' do
      expect(serialized_submission.as_jsonapi[:attributes][:filename]).to eq(submission.filename)
    end
  end
end

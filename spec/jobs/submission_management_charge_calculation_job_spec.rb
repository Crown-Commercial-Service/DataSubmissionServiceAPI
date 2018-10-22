require 'rails_helper'

RSpec.describe SubmissionManagementChargeCalculationJob do
  describe '#perform' do
    let(:framework) { FactoryBot.create(:framework, short_name: 'RM3787') }
    let(:submission) { FactoryBot.create(:submission, framework: framework) }
    let!(:invoice_entry_1) { FactoryBot.create(:invoice_entry, :valid, submission: submission, total_value: 1235.99) }
    let!(:invoice_entry_2) { FactoryBot.create(:invoice_entry, :valid, submission: submission, total_value: 123.45) }
    let!(:order_entry) { FactoryBot.create(:order_entry, :valid, submission: submission, total_value: 123.45) }

    before { SubmissionManagementChargeCalculationJob.new.perform(submission) }

    it 'calculates the management charge for the submission invoice entries' do
      expect(invoice_entry_1.reload.management_charge).to eq 18.5398
      expect(invoice_entry_2.reload.management_charge).to eq 1.8517
      expect(order_entry.reload.management_charge).to be_nil
    end

    it 'marks the submission as ready for review' do
      expect(submission).to be_in_review
    end
  end
end

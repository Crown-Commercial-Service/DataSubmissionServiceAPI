require 'rails_helper'

RSpec.describe SubmissionManagementChargeCalculationJob do
  describe '#perform' do
    let(:framework) { FactoryBot.create(:framework, :with_fdl, short_name: 'RM3787') }
    let(:submission) { FactoryBot.create(:submission, framework: framework) }
    let!(:invoice_entry_1) { FactoryBot.create(:invoice_entry, :valid, submission: submission, total_value: 1235.99) }
    let!(:invoice_entry_2) { FactoryBot.create(:invoice_entry, :valid, submission: submission, total_value: 123.45) }
    let!(:order_entry) { FactoryBot.create(:order_entry, :valid, submission: submission, total_value: 123.45) }

    context 'framework definition source has not changed since the job was enqueued' do
      let(:definition_source_arg) { framework.definition_source }

      before { SubmissionManagementChargeCalculationJob.perform_now(submission, definition_source_arg) }

      it 'calculates the management charge for the submission invoice entries' do
        expect(invoice_entry_1.reload.management_charge).to eq 18.5398
        expect(invoice_entry_2.reload.management_charge).to eq 1.8517
        expect(order_entry.reload.management_charge).to be_nil
      end

      it 'marks the submission as ready for review' do
        expect(submission).to be_in_review
      end
    end

    context 'framework definition source has changed since the job was enqueued' do
      let(:definition_source_arg) { 'A very old value' }

      it 'marks the submission as management_charge_calculation_failed' do
        expect(Rollbar).to receive(:error)

        SubmissionManagementChargeCalculationJob.perform_now(submission, definition_source_arg)

        expect(submission).to be_management_charge_calculation_failed
      end
    end
  end
end

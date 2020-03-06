require 'rails_helper'

RSpec.describe SubmissionManagementChargeCalculationJob do
  describe '#perform' do
    let(:framework) { FactoryBot.create(:framework, :with_fdl, short_name: 'RM3787') }
    let(:submission) { FactoryBot.create(:submission, framework: framework) }
    let!(:invoice_entry_1) { FactoryBot.create(:invoice_entry, :valid, submission: submission, total_value: 1235.99) }
    let!(:invoice_entry_2) { FactoryBot.create(:invoice_entry, :valid, submission: submission, total_value: 123.45) }
    let!(:order_entry) { FactoryBot.create(:order_entry, :valid, submission: submission, total_value: 123.45) }
    let(:definition_source_arg) { framework.definition_source }

    context 'framework definition source has not changed since the job was enqueued' do
      before { SubmissionManagementChargeCalculationJob.perform_now(submission, definition_source_arg) }

      it 'calculates the management charge for the submission invoice entries' do
        expect(invoice_entry_1.reload.management_charge).to eq 18.5398
        expect(invoice_entry_2.reload.management_charge).to eq 1.8517
        expect(order_entry.reload.management_charge).to be_nil
      end

      it 'updates the submission with the management charge total' do
        total = invoice_entry_1.reload.management_charge + invoice_entry_2.reload.management_charge
        expect(submission.management_charge_total).to eq(total)
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

    context 'submission is not in the correct state to have its management charge calculated' do
      it 'raises an exception and does not retry the job' do
        expect_any_instance_of(SubmissionManagementChargeCalculationJob).not_to receive(:retry_job)

        aggregate_failures do
          %w[ingest_failed validation_failed management_charge_calculation_failed].each do |fail_state|
            submission.update!(aasm_state: fail_state)

            expect do
              SubmissionManagementChargeCalculationJob.new.perform(submission, definition_source_arg)
            end.to raise_error(SubmissionManagementChargeCalculationJob::Incalculable)
          end
        end
      end
    end
  end
end

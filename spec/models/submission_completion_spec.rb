require 'rails_helper'

RSpec.describe SubmissionCompletion do
  describe '#perform' do
    let(:user) { FactoryBot.create(:user) }
    let(:complete_submission) { SubmissionCompletion.new(submission, user) }
    let(:task) { FactoryBot.create(:task, status: :in_progress) }

    context 'given an "in review" submission' do
      context 'with validated entries' do
        let(:submission) { FactoryBot.create(:submission_with_validated_entries, aasm_state: 'in_review', task: task) }

        it 'transitions the submission to completed' do
          complete_submission.perform!

          expect(submission).to be_completed
        end

        it 'transitions the task to completed' do
          complete_submission.perform!

          expect(task).to be_completed
        end

        it 'records the user who completed the submission' do
          complete_submission.perform!

          expect(submission.submitted_by).to eq(user)
        end

        it 'records the submission time' do
          submission_time = Time.zone.local(2018, 2, 10, 12, 13, 14)

          travel_to(submission_time) do
            complete_submission.perform!

            expect(submission.submitted_at).to eq(submission_time)
          end
        end

        context 'when SUBMIT_INVOICES env flag is set' do
          around do |example|
            ClimateControl.modify SUBMIT_INVOICES: 'true' do
              example.run
            end
          end

          it 'creates a SubmissionInvoiceSubmissionJob' do
            complete_submission.perform!
            expect(SubmissionInvoiceCreationJob).to have_been_enqueued.with(submission)
          end

          context 'when submission is report_no_business' do
            let(:submission) { FactoryBot.create(:no_business_submission, aasm_state: 'in_review', task: task) }

            it 'does not create a SubmissionInvoiceSubmissionJob' do
              complete_submission.perform!
              expect(SubmissionInvoiceCreationJob).to_not have_been_enqueued
            end
          end

          context 'when submission has 0 management_charge' do
            let(:submission) do
              FactoryBot.create(:submission_with_zero_management_charge, aasm_state: 'in_review', task: task)
            end

            it 'does not create a SubmissionInvoiceSubmissionJob' do
              complete_submission.perform!
              expect(SubmissionInvoiceCreationJob).to_not have_been_enqueued
            end
          end

          context 'when submission has 0 total_spend but non-zero management charge' do
            before do
              allow(submission).to receive(:total_spend).and_return(0)
            end

            it 'creates a SubmissionInvoiceSubmissionJob' do
              complete_submission.perform!
              expect(SubmissionInvoiceCreationJob).to have_been_enqueued
            end
          end
        end

        context 'when SUBMIT_INVOICES env flag is not set' do
          around do |example|
            ClimateControl.modify SUBMIT_INVOICES: nil do
              example.run
            end
          end

          it 'does not create a SubmissionInvoiceSubmissionJob' do
            complete_submission.perform!
            expect(SubmissionInvoiceCreationJob).to_not have_been_enqueued
          end
        end
      end
    end
  end
end

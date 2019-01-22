require 'rails_helper'

RSpec.describe SubmissionCompletion do
  describe '#perform' do
    let(:complete_submission) { SubmissionCompletion.new(submission) }
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

        context 'when SUBMIT_INVOICES env flag is set' do
          around do |example|
            ClimateControl.modify SUBMIT_INVOICES: 'true' do
              example.run
            end
          end

          it 'creates a SubmissionInvoiceSubmissionJob' do
            complete_submission.perform!
            expect(SubmissionInvoiceCreationJob).to have_been_enqueued.with(submission.id)
          end

          context 'when submission is report_no_business' do
            let(:submission) { FactoryBot.create(:no_business_submission, aasm_state: 'in_review', task: task) }

            it 'does not create a SubmissionInvoiceSubmissionJob' do
              complete_submission.perform!
              expect(SubmissionInvoiceCreationJob).to_not have_been_enqueued
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

      context 'with some invalid entries' do
        let(:submission) { FactoryBot.create(:submission_with_invalid_entries, task: task) }

        it 'leaves the submission in the "in_review" state' do
          expect { complete_submission.perform! }.not_to change { submission.aasm_state }
        end

        it 'leaves the task in the "in_progress" state' do
          expect { complete_submission.perform! }.not_to change { task.status }
        end
      end
    end

    context 'given a "processing" submission' do
      let(:submission) { FactoryBot.create(:submission_with_unprocessed_entries, aasm_state: :processing, task: task) }

      it 'leaves the submission in its current state' do
        expect { complete_submission.perform! }.not_to change { submission.aasm_state }
      end
    end
  end
end

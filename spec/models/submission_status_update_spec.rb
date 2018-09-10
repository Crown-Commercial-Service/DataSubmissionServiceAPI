require 'rails_helper'

RSpec.describe SubmissionStatusUpdate do
  describe '#perform' do
    let(:aws_lambda_service_double) { double(trigger: true) }
    let(:submission_status_check) { SubmissionStatusUpdate.new(submission) }

    before do
      allow(AWSLambdaService).to receive(:new).and_return(aws_lambda_service_double)
    end

    context 'given a "processing" submission' do
      context 'with "pending" entries' do
        let(:submission) { FactoryBot.create(:submission_with_pending_entries, aasm_state: :processing) }

        it 'leaves the submission in a "processing" state' do
          submission_status_check.perform!

          expect(submission).to be_processing
        end

        it 'does not trigger a levy calculation' do
          expect(aws_lambda_service_double).not_to receive(:trigger)

          submission_status_check.perform!
        end
      end

      context 'with all entries validated' do
        let(:submission) { FactoryBot.create(:submission_with_validated_entries, aasm_state: :processing) }

        it 'leaves the submission in a "processing" state' do
          submission_status_check.perform!

          expect(submission).to be_processing
        end

        it 'triggers a levy calculation' do
          expect(aws_lambda_service_double).to receive(:trigger)

          submission_status_check.perform!
        end
      end

      context 'with some "pending" entries and some "errored" entries' do
        let(:submission) do
          FactoryBot.create(:submission_with_pending_entries, aasm_state: :processing).tap do |submission|
            create(:errored_submission_entry, submission: submission)
          end
        end

        it 'leaves the submission in a "processing"' do
          submission_status_check.perform!

          expect(submission).to be_processing
        end

        it 'does not trigger a levy calculation' do
          expect(aws_lambda_service_double).not_to receive(:trigger)

          submission_status_check.perform!
        end
      end

      context 'with no "pending" entries remaining, but some having failed validation' do
        let(:submission) { FactoryBot.create(:submission_with_invalid_entries, aasm_state: :processing) }

        it 'transitions the submission to "validation_failed"' do
          submission_status_check.perform!

          expect(submission).to be_validation_failed
        end

        it 'does not trigger a levy calculation' do
          expect(aws_lambda_service_double).not_to receive(:trigger)

          submission_status_check.perform!
        end
      end
    end
  end
end

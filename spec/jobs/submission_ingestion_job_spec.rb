require 'rails_helper'

RSpec.describe SubmissionIngestionJob do
  describe '#perform' do
    context 'when a submission is marked as ingest_failed' do
      let(:submission_file) { create(:submission_file, submission: build(:submission, aasm_state: :ingest_failed)) }

      it 'raises an exception that will discard the job' do
        expect_any_instance_of(SubmissionIngestionJob).not_to receive(:retry_job)
        expect do
          SubmissionIngestionJob.new.perform(submission_file)
        end.to raise_error(SubmissionIngestionJob::IngestFailed)
      end
    end

    context 'the submission file has not persisted' do
      let(:submission_file) do
        build(:submission_file, submission: create(:submission))
      end

      it 'reports to Rollbar and discards the job' do
        allow_any_instance_of(Ingest::Orchestrator).to receive(:perform).and_return(true)

        expect_any_instance_of(SubmissionIngestionJob).not_to receive(:retry_job)

        expect do
          SubmissionIngestionJob.new.perform(submission_file)
        end.to raise_error(ActiveJob::DeserializationError)
      end
    end
  end
end

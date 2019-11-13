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
  end
end

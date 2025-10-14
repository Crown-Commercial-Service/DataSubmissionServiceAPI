require 'rails_helper'

RSpec.describe CleanupSubmissionEntriesJob, type: :job do
  describe '#perform' do
    let!(:task) { FactoryBot.create(:task) }
    let!(:failed_submission1) { FactoryBot.create(:submission_with_invalid_entries, task: task) }
    let!(:failed_submission2) { FactoryBot.create(:submission_with_invalid_entries, task: task) }
    let!(:submission_entry) { FactoryBot.create(:submission_entry, submission: failed_submission1) } 

    context 'when dry_run is true' do
      it 'does not delete entries and logs the intended deletions' do
        expect(Rollbar).to receive(:info).with("Dry run: would delete 1 entries for Submission ID #{failed_submission1.id}.")
        expect {
          described_class.perform_now(dry_run: true)
        }.not_to change(SubmissionEntry, :count)
        expect(failed_submission1.reload.cleanup_processed).to be_falsey
        expect(failed_submission2.reload.cleanup_processed).to be_falsey
      end
    end

    context 'when dry_run is false' do
      it 'deletes entries and marks submissions as processed' do
        expect(Rollbar).to receive(:info).with("Task ID #{task.id}: Processed 1 failed submissions, deleted 1 entries.")
        expect {
          described_class.perform_now(dry_run: false)
        }.to change(SubmissionEntry, :count).by(-1)
        expect(failed_submission1.reload.cleanup_processed).to be_truthy
      end
    end

    context 'when there are no validation failed submissions' do
      before do
        failed_submission1.update(aasm_state: 'ingest_failed')
        failed_submission2.update(aasm_state: 'completed')
      end

      it 'does not perform any deletions or updates' do
        expect(Rollbar).not_to receive(:info)
        expect {
          described_class.perform_now(dry_run: false)
        }.not_to change(SubmissionEntry, :count)
        expect(failed_submission1.reload.cleanup_processed).to be_falsey
      end  
    end
  end
end
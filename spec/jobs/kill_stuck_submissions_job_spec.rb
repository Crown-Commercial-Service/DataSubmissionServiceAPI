require 'rails_helper'
RSpec.describe KillStuckSubmissionsJob, type: :job do
  describe '#perform' do
    let!(:stuck_submission) { FactoryBot.create(:submission, aasm_state: 'processing', updated_at: 25.hours.ago) }
    let!(:not_stuck_submission) { FactoryBot.create(:submission, aasm_state: 'processing', updated_at: 23.hours.ago) }

    it 'updates stuck submissions to ingest_failed' do
      expect { described_class.perform_now }.to change {
        stuck_submission.reload.aasm_state
      }.from('processing').to('ingest_failed')
      expect(not_stuck_submission.reload.aasm_state).to eq('processing')
    end

    it 'does not update submissions that are not stuck' do
      described_class.perform_now
      expect(not_stuck_submission.reload.aasm_state).to eq('processing')
    end
  end
end

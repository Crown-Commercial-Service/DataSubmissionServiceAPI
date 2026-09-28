require 'rails_helper'

RSpec.describe PurgeExpiredNotificationBatchesJob do
  describe '#perform' do
    it 'purges expired notification batches' do
      allow(NotificationBatch).to receive(:purge_expired!)

      described_class.perform_now

      expect(NotificationBatch)
        .to have_received(:purge_expired!)
    end
  end
end

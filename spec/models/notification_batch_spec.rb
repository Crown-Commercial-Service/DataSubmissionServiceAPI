require 'rails_helper'

RSpec.describe NotificationBatch do
  describe 'associations' do
    it { is_expected.to have_many(:notification_deliveries).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:notification_type) }
    it { is_expected.to validate_presence_of(:template_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:started_at) }
  end

  describe '.expired' do
    subject(:expired_batches) { described_class.expired }

    let!(:expired_batch) do
      described_class.create!(
        {
          notification_type: 'due',
          template_id: 'template-id',
          status: 'submitted',
          started_at: 31.days.ago,
          created_at: 31.days.ago
        }
      )
    end

    let!(:current_batch) do
      described_class.create!(
        {
          notification_type: 'due',
          template_id: 'template-id',
          status: 'submitted',
          started_at: 29.days.ago,
          created_at: 29.days.ago
        }
      )
    end

    it 'includes batches older than the retention period' do
      expect(expired_batches).to include(expired_batch)
    end

    it 'does not include batches within the retention period' do
      expect(expired_batches).not_to include(current_batch)
    end
  end

  describe '.purge_expired!' do
    let!(:expired_batch) do
      described_class.create!(
        {
          notification_type: 'due',
          template_id: 'template-id',
          status: 'submitted',
          started_at: 31.days.ago,
          created_at: 31.days.ago
        }
      )
    end

    let!(:current_batch) do
      described_class.create!(
        {
          notification_type: 'due',
          template_id: 'template-id',
          status: 'submitted',
          started_at: 29.days.ago,
          created_at: 29.days.ago
        }
      )
    end

    before do
      expired_batch.notification_deliveries.create!(
        email: 'expired@example.com',
        supplier_name: 'Expired Supplier',
        reference: 'expired-reference',
        status: 'delivered'
      )

      current_batch.notification_deliveries.create!(
        email: 'current@example.com',
        supplier_name: 'Current Supplier',
        reference: 'current-reference',
        status: 'delivered'
      )
    end

    it 'destroys expired batches and their associated deliveries' do
      expect { described_class.purge_expired! }.to change { described_class.count }.by(-1)
      expect(NotificationDelivery.where(reference: 'expired-reference')).to be_empty
    end

    it 'retains current batches and their associated deliveries' do
      expect { described_class.purge_expired! }.not_to change {
        NotificationDelivery.where(reference: 'current-reference').count
      }
    end
  end
end

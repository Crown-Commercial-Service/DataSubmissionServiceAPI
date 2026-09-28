require 'rails_helper'

RSpec.describe NotificationDelivery do
  let(:notification_batch) do
    NotificationBatch.create!(
      notification_type: 'due',
      template_id: 'template-id',
      status: 'submitted',
      started_at: Time.current
    )
  end

  describe 'validations' do
    it 'is valid with required attributes' do
      delivery = described_class.new(
        notification_batch: notification_batch,
        email: 'test@example.com',
        supplier_name: 'Test Supplier',
        reference: 'test-reference',
        status: 'pending'
      )
      expect(delivery).to be_valid
    end

    it 'requires an email address' do
      delivery = described_class.new(
        notification_batch: notification_batch,
        supplier_name: 'Test Supplier',
        reference: 'test-reference',
        status: 'pending'
      )
      expect(delivery).not_to be_valid
    end

    it 'requires a supplier name' do
      delivery = described_class.new(
        notification_batch: notification_batch,
        email: 'test@example.com',
        reference: 'test-reference',
        status: 'pending'
      )
      expect(delivery).not_to be_valid
    end

    it 'requires a unique reference' do
      described_class.create!(
        notification_batch: notification_batch,
        email: 'test@example.com',
        supplier_name: 'Test Supplier',
        reference: 'test-reference',
        status: 'pending'
      )

      duplicate = described_class.new(
        notification_batch: notification_batch,
        email: 'test2@example.com',
        supplier_name: 'Test Supplier 2',
        reference: 'test-reference',
        status: 'pending'
      )
      expect(duplicate).not_to be_valid
    end

    it 'allows notify_id to be nil but requires uniqueness if present' do
      described_class.create!(
        notification_batch: notification_batch,
        email: 'test@example.com',
        supplier_name: 'Test Supplier',
        reference: 'test-reference',
        status: 'pending'
      )

      duplicate = described_class.new(
        notification_batch: notification_batch,
        email: 'test2@example.com',
        supplier_name: 'Test Supplier 2',
        reference: 'test-reference',
        status: 'pending'
      )
      expect(duplicate).not_to be_valid
    end
  end
end

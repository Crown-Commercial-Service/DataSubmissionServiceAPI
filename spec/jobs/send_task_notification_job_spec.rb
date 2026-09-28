require 'rails_helper'

RSpec.describe SendTaskNotificationJob do
  subject(:perform_job) do
    described_class.perform_now(
      delivery.id,
      personalisation
    )
  end

  let(:batch) do
    NotificationBatch.create!(
      notification_type: 'due',
      template_id: 'template-id',
      status: 'submitted',
      started_at: Time.current
    )
  end

  let(:delivery) do
    batch.notification_deliveries.create!(
      email: 'test@example.com',
      supplier_name: 'Test Supplier',
      reference: 'test-reference',
      status: 'pending'
    )
  end

  let(:personalisation) do
    {
      person_name: 'Alice Example',
      supplier_name: 'Test Supplier',
      reporting_month: 'January 2026',
    }
  end

  let(:notify) { instance_double(Notify) }
  let(:response) { instance_double('NotificationResponse', id: 'notify-id') }

  before do
    allow(Notify).to receive(:new).and_return(notify)
    allow(notify).to receive(:send_email).and_return(response)
  end

  it 'sends the email using the Notify service' do
    perform_job

    expect(notify).to have_received(:send_email).with(
      template_id: batch.template_id,
      email: delivery.email,
      vars: personalisation,
      reference: delivery.reference
    )
  end

  it 'stores the GOV.UK Notify notification ID' do
    perform_job

    expect(delivery.reload.notify_id).to eq('notify-id')
  end

  it 'marks the delivery as created' do
    perform_job

    expect(delivery.reload.status).to eq('created')
  end

  it 'records when the notification was sent' do
    freeze_time do
      perform_job

      expect(delivery.reload.sent_at).to eq(Time.current)
    end
  end
end

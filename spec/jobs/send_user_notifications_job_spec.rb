require 'rails_helper'

RSpec.describe SendUserNotificationsJob do
  include ActiveJob::TestHelper

  let(:month) { 9 }
  let(:year) { 2026 }

  let(:notification) do
    {
      email: 'alice@example.com',
      supplier_name: 'Supplier A',
      personalisation: {
        person_name: 'Alice Example',
        supplier_name: 'Supplier A',
        framework: ['RM001 - Framework 1', 'RM002 - Framework 2']
      }
    }
  end

  let(:selector) { double('notification selector') }

  config = {
    'due' => 'GOV_NOTIFY_ANTICIPATED_USER_TEMPLATE_ID',
    'duetoday' => 'GOV_NOTIFY_DUE_TODAY_USER_TEMPLATE_ID',
    'overdue' => 'GOV_NOTIFY_OVERDUE_USER_TEMPLATE_ID',
    'late' => 'GOV_NOTIFY_LATE_USER_TEMPLATE_ID',
    'unfinished' => 'GOV_NOTIFY_UNFINISHED_USER_TEMPLATE_ID'
  }

  config.each do |type, template_env|
    context "when notification_type is '#{type}'" do
      let(:notification_type) { type }

      around do |example|
        ClimateControl.modify(**{ template_env => 'test-template-id' }) do
          example.run
        end
      end

      before do
        selector_class = if type == 'unfinished'
                           Task::UnfinishedUserNotifications
                         else
                           Task::UserNotificationRecipients
                         end

        arguments = if type == 'unfinished'
                      {}
                    else
                      {
                        month: month,
                        year: year,
                        type: type == 'due' ? :anticipated : :incomplete
                      }
                    end

        if arguments.empty?
          allow(selector_class)
            .to receive(:new)
            .with(no_args)
            .and_return(selector)
        else
          allow(selector_class)
            .to receive(:new)
            .with(**arguments)
            .and_return(selector)
        end

        allow(selector)
          .to receive(:each)
          .and_yield(notification)
      end

      def perform_notifications_job
        arguments = { notification_type: notification_type }

        arguments.merge!(month: month, year: year) unless notification_type == 'unfinished'

        described_class.perform_now(**arguments)
      end

      it 'creates a submitted batch with the correct template' do
        expect do
          perform_notifications_job
        end.to change(NotificationBatch, :count).by(1)

        batch = NotificationBatch.last

        expect(batch.notification_type).to eq(type)
        expect(batch.template_id).to eq('test-template-id')
        expect(batch.status).to eq('submitted')
        expect(batch.started_at).to be_present
        expect(batch.completed_at).to be_present
      end

      it 'creates a pending delivery' do
        expect do
          perform_notifications_job
        end.to change(NotificationDelivery, :count).by(1)

        delivery = NotificationDelivery.last

        expect(delivery.email).to eq(notification[:email])
        expect(delivery.supplier_name).to eq(notification[:supplier_name])
        expect(delivery.reference).to be_present
        expect(delivery.status).to eq('pending')
      end

      it 'enqueues the individual send job' do
        perform_notifications_job

        delivery = NotificationDelivery.last

        expect(SendTaskNotificationJob)
          .to have_been_enqueued.with(
            delivery.id,
            notification[:personalisation]
          )
      end
    end
  end

  it 'does not create a second batch with the same run key' do
    arguments = {
      notification_type: 'due',
      month: 9,
      year: 2024,
      run_key: 'due-2024-09-01'
    }

    described_class.perform_now(**arguments)

    expect do
      described_class.perform_now(**arguments)
    end.not_to change(NotificationBatch, :count)
  end

  it 'rejects unknown notification types' do
    expect do
      described_class.perform_now(notification_type: 'unknown')
    end.to raise_error(KeyError)
  end

  it 'rejects missing reporting periods' do
    expect do
      described_class.perform_now(notification_type: 'due')
    end.to raise_error(ArgumentError, /Month and year must be provided/)
  end
end

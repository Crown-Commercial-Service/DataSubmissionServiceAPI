require 'rails_helper'

RSpec.describe SendAnticipatedUserNotificationsJob do
  subject(:perform_job) do
    described_class.perform_now(month: 9, year: 2024)
  end

  let(:notifications) do
    [
      {
        email: 'alice@example.com',
        supplier_name: 'Supplier 1',
        personalisation: {
          person_name: 'Alice Example',
          supplier_name: 'Supplier 1'
        }
      },
      {
        email: 'bob@example.com',
        supplier_name: 'Supplier 2',
        personalisation: {
          person_name: 'Bob Example',
          supplier_name: 'Supplier 2'
        }
      }
    ]
  end

  let(:notification_selector) { instance_double(Task::AnticipatedUserNotifications) }

  before do
    stub_const(
      'SendAnticipatedUserNotificationsJob::TEMPLATE_ID',
      'template-id'
    )

    allow(Task::AnticipatedUserNotifications)
      .to receive(:new)
      .with(month: 9, year: 2024)
      .and_return(notification_selector)

    allow(notification_selector)
      .to receive(:each)
      .and_yield(notifications.first)
      .and_yield(notifications.second)
  end

  it 'creates a notification batch' do
    expect { perform_job }
      .to change(NotificationBatch, :count).by(1)

    batch = NotificationBatch.last

    expect(batch.notification_type).to eq('due')
    expect(batch.period_month).to eq(9)
    expect(batch.period_year).to eq(2024)
    expect(batch.template_id).to eq('template-id')
    expect(batch.status).to eq('submitted')
  end

  it 'creates a delivery for each notification' do
    expect { perform_job }
      .to change(NotificationDelivery, :count).by(2)

    expect(NotificationDelivery.pluck(:email)).to contain_exactly(
      'alice@example.com',
      'bob@example.com'
    )
  end

  it 'stores the supplier against each delivery' do
    perform_job

    expect(
      NotificationDelivery.pluck(:email, :supplier_name)
    ).to contain_exactly(
      ['alice@example.com', 'Supplier 1'],
      ['bob@example.com', 'Supplier 2']
    )
  end

  it 'creates a unique reference for each delivery' do
    perform_job

    references = NotificationDelivery.pluck(:reference)

    expect(references).to all(be_present)
    expect(references.uniq.length).to eq(2)
  end

  it 'enqueues a send job for each delivery' do
    expect { perform_job }
      .to have_enqueued_job(SendTaskNotificationJob).exactly(2).times
  end

  it 'passes the correct personalisation to each send job' do
    perform_job

    alice_delivery = NotificationDelivery.find_by!(email: 'alice@example.com')

    expect(SendTaskNotificationJob).to have_been_enqueued.with(
      alice_delivery.id,
      {
        person_name: 'Alice Example',
        supplier_name: 'Supplier 1'
      }
    )
  end

  it 'records when the batch has finished submitting notifications' do
    freeze_time
    perform_job

    expect(NotificationBatch.last.completed_at).to eq(Time.current)
  end

  context 'when generating the notification fails' do
    before do
      allow(notification_selector)
        .to receive(:each)
        .and_raise(StandardError, 'Something went wrong')
    end

    it 'marks the batch as failed' do
      expect { perform_job }.to raise_error(
        StandardError,
        'Something went wrong'
      )

      expect(NotificationBatch.last.status).to eq('failed')
    end

    it 'records when the batch has failed' do
      freeze_time do
        expect { perform_job }.to raise_error(StandardError)

        expect(NotificationBatch.last.completed_at).to eq(Time.current)
      end
    end
  end
end

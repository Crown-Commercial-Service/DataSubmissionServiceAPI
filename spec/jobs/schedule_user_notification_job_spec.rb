require 'rails_helper'

RSpec.describe ScheduleUserNotificationJob do
  include ActiveJob::TestHelper

  around do |example|
    travel_to(Time.zone.local(2026, 9, 12, 12)) do
      example.run
    end
  end

  it 'schedules due notifications for current month' do
    described_class.perform_now('due')

    expect(SendUserNotificationsJob).to have_been_enqueued.with(
      notification_type: 'due',
      month: 9,
      year: 2026,
      run_key: 'due-2026-09-12'
    )
  end

  %w[duetoday overdue late].each do |type|
    it "schedules #{type} notifications for previous month" do
      described_class.perform_now(type)

      expect(SendUserNotificationsJob).to have_been_enqueued.with(
        notification_type: type,
        month: 9,
        year: 2026,
        run_key: "#{type}-2026-09-12"
      )
    end
  end

  it 'schedules unfinished notifications without month and year' do
    described_class.perform_now('unfinished')

    expect(SendUserNotificationsJob).to have_been_enqueued.with(
      notification_type: 'unfinished',
      run_key: 'unfinished-2026-09-12'
    )
  end

  it 'rejects unknown notification types' do
    expect do
      described_class.perform_now('unknown')
    end.to raise_error(ArgumentError, 'Unknown notification type: unknown.')
  end
end

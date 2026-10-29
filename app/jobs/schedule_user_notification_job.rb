class ScheduleUserNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_type)
    type = notification_type.to_s
    today = Time.zone.today

    unless SendUserNotificationsJob::NOTIFICATION_TYPES.key?(type)
      raise ArgumentError, "Unknown notification type: #{notification_type}."
    end

    arguments = {
      notification_type: type,
      run_key: "#{type}-#{today.strftime('%Y-%m-%d')}"
    }

    unless type == 'unfinished'
      period = reporting_period_for(type, today)

      arguments.merge!(month: period.month, year: period.year)
    end

    SendUserNotificationsJob.perform_later(**arguments)
  end

  private

  def reporting_period_for(type, today)
    case type
    when 'due', 'duetoday', 'overdue', 'late'
      today.beginning_of_month
    else
      raise ArgumentError, "Unknown notification type: #{type}."
    end
  end
end

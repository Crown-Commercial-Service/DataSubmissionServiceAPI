class ScheduleUserNotificationsJob < ApplicationJob
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
      reporting_period = Time.zone.today.prev_month
      arguments.merge!(month: reporting_period.month, year: reporting_period.year)
    end

    SendUserNotificationsJob.perform_later(**arguments)
  end
end

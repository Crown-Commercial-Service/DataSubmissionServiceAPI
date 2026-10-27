require 'bank_holidays'

class ScheduleWorkingDayNotificationsJob < ApplicationJob
  queue_as :default

  WORKING_DAY_TYPES = {
    4 => 'unfinished',
    6 => 'overdue',
    11 => 'late'
  }.freeze

  def perform(notification_type)
    today = Time.zone.today
    day_number = working_day_number(today)

    notification_type = WORKING_DAY_TYPES[day_number]
    return unless notification_type

    arguments = {
      notification_type: notification_type,
      run_key: "#{notification_type}-#{today.strftime('%Y-%m-%d')}"
    }

    unless notification_type == 'unfinished'
      arguments[:month] = today.month
      arguments[:year] = today.year
    end

    SendUserNotificationsJob.perform_later(**arguments)
  end

  private

  def working_day_number(date)
    holidays = BankHolidays.allow

    (date.beginning_of_month..date).count do |d|
      !d.saturday? && !d.sunday? && !holidays.include?(d)
    end
  end
end
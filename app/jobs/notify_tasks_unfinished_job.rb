require 'bank_holidays'

class NotifyTasksUnfinishedJob < ApplicationJob
  def perform
    return unless [fourth_working_day, ninth_working_day].include?(Time.zone.today)

    Task::UnfinishedUserNotificationList.new(logger: logger).notify
  end

  private

  def fourth_working_day
    dates = Range.new(Time.zone.today.beginning_of_month, Time.zone.today.end_of_month).to_a
    dates = dates.reject { |date| date.saturday? || date.sunday? || bank_holidays.include?(date) }
    dates[3]
  end

  def ninth_working_day
    dates = Range.new(Time.zone.today.beginning_of_month, Time.zone.today.end_of_month).to_a
    dates = dates.reject { |date| date.saturday? || date.sunday? || bank_holidays.include?(date) }
    dates[8]
  end

  def bank_holidays
    @bank_holidays ||= BankHolidays.all
  end
end

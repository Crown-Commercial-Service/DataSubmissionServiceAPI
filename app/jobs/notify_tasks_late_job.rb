require 'bank_holidays'

class NotifyTasksLateJob < ApplicationJob
  def perform
    return unless Time.zone.today == eleventh_working_day

    Task::OverdueUserNotificationList.new(month: submission_period_month, year: submission_period_year,
                                          template_id: 'b45a8f1c-a612-4266-910f-f5ce42df2b56', logger: logger).notify
  end

  private

  def submission_period_month
    Date.current.last_month.month
  end

  def submission_period_year
    Date.current.last_month.year
  end

  def eleventh_working_day
    dates = Range.new(Time.zone.today.beginning_of_month, Time.zone.today.end_of_month).to_a
    dates = dates.reject { |date| date.saturday? || date.sunday? || bank_holidays.include?(date) }
    dates[10]
  end

  def bank_holidays
    @bank_holidays ||= BankHolidays.all
  end
end

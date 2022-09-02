require 'bank_holidays'

class NotifyTasksOverdueJob < ApplicationJob
  def perform
    return unless Time.zone.today == sixth_working_day

    Task::OverdueUserNotificationList.new(month: submission_period_month, year: submission_period_year,
                                          template_id: 'e7afcd6c-51c1-4cb0-adf5-a0947909a7a2', logger: logger).notify
  end

  private

  def submission_period_month
    Date.current.last_month.month
  end

  def submission_period_year
    Date.current.last_month.year
  end

  def sixth_working_day
    dates = Range.new(Time.zone.today.beginning_of_month, Time.zone.today.end_of_month).to_a
    dates = dates.reject { |date| date.saturday? || date.sunday? || bank_holidays.include?(date) }
    dates[5]
  end

  def bank_holidays
    @bank_holidays ||= BankHolidays.all
  end
end

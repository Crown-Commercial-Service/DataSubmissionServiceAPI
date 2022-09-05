class NotifyTasksUnfinishedJob < ApplicationJob
  def perform
    return unless [fourth_working_day, ninth_working_day].include?(Time.zone.today)

    Task::UnfinishedUserNotificationList.new(logger: logger).notify
  end

  private

  def fourth_working_day
    @fourth_working_day ||= Task::SubmissionWindow.new(Date.current.last_month.year,
                                                       Date.current.last_month.month).on_working_day(4)
  end

  def ninth_working_day
    @ninth_working_day ||= Task::SubmissionWindow.new(Date.current.last_month.year,
                                                      Date.current.last_month.month).on_working_day(9)
  end
end

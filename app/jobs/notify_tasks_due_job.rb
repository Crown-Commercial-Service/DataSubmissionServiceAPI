class NotifyTasksDueJob < ApplicationJob
  def perform
    Task::AnticipatedUserNotificationList.new(month: submission_period_month, year: submission_period_year,
                                              logger: logger).notify
  end

  private

  def submission_period_month
    Date.current.last_month.month
  end

  def submission_period_year
    Date.current.last_month.year
  end
end

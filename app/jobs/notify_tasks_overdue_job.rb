class NotifyTasksOverdueJob < ApplicationJob
  def perform
    case Time.zone.today
    when sixth_working_day
      Task::OverdueUserNotificationList.new(month: submission_period_month, year: submission_period_year,
                                            template_id: 'e7afcd6c-51c1-4cb0-adf5-a0947909a7a2', logger: logger).notify
    when eleventh_working_day
      Task::OverdueUserNotificationList.new(month: submission_period_month, year: submission_period_year,
                                            template_id: 'b45a8f1c-a612-4266-910f-f5ce42df2b56', logger: logger).notify
    end
  end

  private

  def submission_period_month
    Date.current.last_month.month
  end

  def submission_period_year
    Date.current.last_month.year
  end

  def sixth_working_day
    @sixth_working_day ||= Task::SubmissionWindow.new(submission_period_year, 
                                                      submission_period_month).on_working_day(6)
  end

  def eleventh_working_day
    @eleventh_working_day ||= Task::SubmissionWindow.new(submission_period_year,
                                                         submission_period_month).on_working_day(11)
  end
end

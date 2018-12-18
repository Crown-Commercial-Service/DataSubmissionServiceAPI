##
# Generates supplier tasks for the current period
#
class MonthlyTasksGenerationJob < ApplicationJob
  def perform
    Task::Generator.new(month: submission_period_month, year: submission_period_year, logger: logger).generate!
  end

  private

  def submission_period_month
    Date.current.last_month.month
  end

  def submission_period_year
    Date.current.last_month.year
  end
end

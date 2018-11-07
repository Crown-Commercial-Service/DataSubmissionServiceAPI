# Report on the total spend and management charge for a given submission window
#
class TotalsReporter
  include ActionView::Helpers::NumberHelper

  attr_reader :reporting_period_date

  def initialize(reporting_period_date)
    @reporting_period_date = reporting_period_date
  end

  def report
    STDERR.puts "Calculating spend and management charge for #{reporting_period_date.strftime('%B %Y')} tasks"

    STDERR.puts "Total spend is approximately #{as_currency(total_spend)}"
    STDERR.puts "Total management charge is approximately #{as_currency(management_charge)}"
  end

  def total_spend
    SubmissionEntry.invoices.where(submission_id: completed_submission_ids).sum(:total_value)
  end

  def management_charge
    SubmissionEntry.invoices.where(submission_id: completed_submission_ids).sum(:management_charge)
  end

  private

  def as_currency(number)
    number_to_currency(number, precision: 0, unit: '£')
  end

  def tasks_scope
    @tasks_scope ||= Task.where(period_year: reporting_period_date.year, period_month: reporting_period_date.month)
  end

  def completed_submission_ids
    # NB: 'uniq' added to prevent miscalulation when a task has more than one completed submission
    @completed_submission_ids ||= tasks_scope
                                  .joins(:latest_submission)
                                  .merge(Submission.completed)
                                  .map { |t| t.latest_submission.id }
                                  .uniq
  end
end

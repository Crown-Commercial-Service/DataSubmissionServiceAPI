# A temporary class to report on the total spend and management charge for a
# given submission window whilst we are without per-entry storage of the spend
# and management charge.
#
# This class should become redundant once we are capturing the total  value and
# management charge per-entry. At that point it should be removed and/or
# replaced by something that leans on the data available.
class TemporaryTotalsReporter
  include ActionView::Helpers::NumberHelper

  FRAMEWORK_LOOKUPS = {
    'CM/OSG/05/3565' => ['0', 'Total Spend'],
    'RM1031' => ['0.5', 'Total Charge (Ex VAT)'],
    'RM1070' => [
      '0.5',
      'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT'
    ],
    'RM3710' => ['0.5', 'Total Charge (Ex VAT)'],
    'RM3754' => ['0.5', 'Total Charge (ex VAT)'],
    'RM3756' => ['1.5', 'Total Cost (ex VAT)'],
    'RM3767' => ['1', 'Total Cost (ex VAT)'],
    'RM3772' => ['0.5', 'Total Charge (Ex VAT)'],
    'RM3786' => ['1.5', 'Total Cost (ex VAT)'],
    'RM3787' => ['1.5', 'Total Cost (ex VAT)'],
    'RM3797' => ['1', 'Total Charge (Ex VAT)'],
    'RM807' => ['0.5', 'Total Charges (ex VAT)'],
    'RM849' => ['0.5', 'Invoice Line Total Value ex VAT and Expenses'],
    'RM858' => ['0.5', 'Invoice Line Total Value ex VAT']
  }.freeze

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
    completed_submissions.sum do |submission|
      spend_column = FRAMEWORK_LOOKUPS.fetch(submission.framework.short_name).last

      submission.entries.invoices.pluck(:data).sum { |data| coerce_amount_to_decimal(data[spend_column]) }
    end
  end

  def management_charge
    completed_submissions.sum do |submission|
      spend_column = FRAMEWORK_LOOKUPS.fetch(submission.framework.short_name).last
      percentage = FRAMEWORK_LOOKUPS.fetch(submission.framework.short_name).first
      total = submission.entries.invoices.pluck(:data).sum { |data| coerce_amount_to_decimal(data[spend_column]) }
      total * BigDecimal(percentage) / 100
    end
  end

  private

  def coerce_amount_to_decimal(currency_amount)
    if currency_amount.is_a? String
      BigDecimal(currency_amount.tr('£,', ''))
    else
      BigDecimal(currency_amount.to_s)
    end
  end

  def as_currency(number)
    number_to_currency(number, precision: 0, unit: '£')
  end

  def tasks_scope
    @tasks_scope ||= Task.where(period_year: reporting_period_date.year, period_month: reporting_period_date.month)
  end

  def completed_submissions
    @completed_submissions ||= tasks_scope
                               .joins(latest_submission: :framework)
                               .merge(Submission.completed)
                               .map(&:latest_submission)
  end
end

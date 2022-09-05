require 'bank_holidays'

class Task
  class SubmissionWindow
    NUMBER_OF_REPORTING_DAYS = 5

    attr_reader :year, :month

    def initialize(year, month)
      @month = month
      @year = year
    end

    def due_date
      @due_date ||= last_day_of_submission_window
    end

    def on_working_day(number)
      working_days[number - 1]
    end

    private

    def first_day_of_submission_window
      Date.new(year, month).end_of_month.next_day
    end

    def last_day_of_submission_window
      working_days.take(NUMBER_OF_REPORTING_DAYS).last
    end

    def working_days
      dates = Range.new(first_day_of_submission_window, first_day_of_submission_window + 20.days)
      dates.reject { |date| date.saturday? || date.sunday? || bank_holidays.include?(date) }
    end

    def bank_holidays
      @bank_holidays ||= BankHolidays.all
    end
  end
end

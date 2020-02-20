require 'bank_holidays'

class Task
  class SubmissionWindow
    attr_reader :year, :month

    def initialize(year, month)
      @month = month
      @year = year
    end

    def due_date
      submission_window.last + offset_for_bank_holidays
    end

    private

    def submission_window
      Range.new(first_of_month, (first_of_month + 6.days))
    end

    def first_of_month
      Date.new(year, month).end_of_month.next_day
    end

    def offset_for_bank_holidays
      (submission_window.to_a & BankHolidays.all).size
    end
  end
end

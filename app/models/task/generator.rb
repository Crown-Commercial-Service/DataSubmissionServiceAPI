require 'bank_holidays'

class Task
  # Used to generate the monthly tasks for suppliers and the frameworks they
  # have an agreement in place for.
  class Generator
    attr_reader :logger, :month, :year

    def initialize(month:, year:, logger: Rails.logger)
      @month = month
      @year = year
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def generate!
      info "Creating tasks for #{Date::MONTHNAMES[month]} #{year}, falling due on #{due_date}"

      agreements.find_each do |agreement|
        task_attributes = task_attributes_for_agreement(agreement)

        if Task.exists?(task_attributes)
          warn "Task already exists for #{agreement.supplier.name} on #{agreement.framework.short_name}"
        else
          info "Creating task for #{agreement.supplier.name} on #{agreement.framework.short_name}"
          Task.create!(task_attributes)
        end
      end
    end

    private

    def agreements
      Agreement.includes(:framework, :supplier)
    end

    def task_attributes_for_agreement(agreement)
      {
        framework: agreement.framework,
        supplier: agreement.supplier,
        period_month: month,
        period_year: year,
        due_on: due_date
      }
    end

    def due_date
      submission_window.last + offset_for_bank_holidays
    end

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

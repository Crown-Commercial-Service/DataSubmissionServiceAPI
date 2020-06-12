require 'csv'

class Task
  # Used to generate a 'late' CSV for all users
  # of suppliers with incomplete submissions in the
  # given year/month period. Outputs via +puts+ objects
  # that respond_to? it (+STDOUT+ or +File+ being usual)
  class OverdueUserNotificationList
    HEADER = ['email address', 'due_date', 'person_name', 'supplier_name', 'reporting_month'].freeze

    attr_reader :logger, :output, :month, :year

    def initialize(month:, year:, output: STDOUT, logger: Rails.logger)
      @month = month
      @year = year
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def generate
      logger.info "Generating late contacts for #{year}, #{month}"

      output.puts(CSV.generate_line(header))

      suppliers.each do |supplier|
        supplier.active_users.each do |user|
          output.puts csv_line_for(user, supplier)
        end
      end
    end

    private

    def csv_line_for(user, supplier)
      framework_csv_columns = framework_csv_columns_for(supplier)
      return if framework_csv_columns.all?(nil)

      CSV.generate_line(
        [user.email, due_date, user.name, supplier.name, reporting_month] + framework_csv_columns
      )
    end

    def header
      HEADER + frameworks_header
    end

    def reporting_month
      @reporting_month ||= [Date::MONTHNAMES[month], year].join(' ')
    end

    def due_date
      @due_date ||= SubmissionWindow.new(year, month).due_date.to_s(:day_month_year)
    end

    def frameworks
      @frameworks ||= Framework.published.order(:short_name)
    end

    def frameworks_header
      Array.new(framework_column_count, 'framework')
    end

    def framework_column_count
      @framework_column_count ||= suppliers.map { |supplier| supplier.tasks.pluck(:framework_id).uniq.size }.max || 0
    end

    def framework_csv_columns_for(supplier)
      frameworks_with_incomplete_tasks = supplier.tasks.map { |task| task.framework.short_name }.sort

      frameworks_with_incomplete_tasks.fill(nil, frameworks_with_incomplete_tasks.size...framework_column_count)
    end

    def suppliers
      Supplier.includes(:active_users, :tasks).joins(:tasks).merge(incomplete_tasks_relation).distinct
    end

    def incomplete_tasks_relation
      @incomplete_tasks_relation ||= Task.where(period_month: month, period_year: year).incomplete
    end
  end
end

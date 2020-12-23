require 'csv'

class Task
  # Used to generate a 'unfinished' CSV for all users
  # of suppliers with unfinished submissions in the
  # given year/month period, due to ingest or validation
  # failure, or still being in review. Outputs via +puts+
  # objects that respond_to? it (+STDOUT+ or +File+ being usual)
  class UnfinishedUserNotificationList
    HEADER = ['email address', 'person_name', 'supplier_name', 'task_name', 'task_status'].freeze
    UNFINISHED_STATUSES = ['validation_failed', 'ingest_failed', 'in_review'].freeze

    attr_reader :logger, :output, :month, :year

    def initialize(month:, year:, output: STDOUT, logger: Rails.logger)
      @month = month
      @year = year
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def generate
      logger.info "Generating contacts with unfinished submissions."

      output.puts(CSV.generate_line(HEADER))

      suppliers.each do |supplier|
        supplier.active_users.each do |user|
          user.submissions.each do |submission|
            output.puts csv_line_for(user, supplier, submission)
          end
        end
      end
    end

    private

    def csv_line_for(user, supplier, submission)
      CSV.generate_line(
        [user.email, user.name, supplier.name, task_name(submission), task_status(submission)]
      )
    end

    def task_month_and_year(task)
      "#{Date::MONTHNAMES[task.period_month]} #{task.period_year}"
    end

    def task_name(submission)
      task = submission.task
      "#{task.framework.short_name} - #{task.framework.name} - #{task_month_and_year(task)}"
    end

    def task_status(submission)
      submission.aasm_state.to_s
    end

    def suppliers
      # rubocop:disable Metrics/LineLength
      Supplier.includes(:active_users, :submissions).joins(:submissions).merge(unfinished_submissions_relation).distinct
      # rubocop:enable Metrics/LineLength
    end

    def unfinished_submissions_relation
      @unfinished_submissions_relation ||= Submission.where(aasm_state: UNFINISHED_STATUSES)
    end
  end
end

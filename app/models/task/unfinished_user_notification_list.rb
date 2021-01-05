require 'csv'

class Task
  # Used to generate a 'unfinished' CSV for all users
  # of suppliers with unfinished submissions, due to ingest
  # or validation failure, or still being in review. Outputs via +puts+
  # objects that respond_to? it (+STDOUT+ or +File+ being usual)
  class UnfinishedUserNotificationList
    UNFINISHED_STATUSES = ['validation_failed', 'ingest_failed', 'in_review'].freeze
    HEADER = ['email address', 'person_name', 'supplier_name', 'task_name'] + UNFINISHED_STATUSES.freeze

    attr_reader :logger, :output

    def initialize(output: STDOUT, logger: Rails.logger)
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def generate
      logger.info 'Generating contacts with unfinished submissions.'

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
        [user.email, user.name, supplier.name, task_name(submission), validation_failed?(submission), ingest_failed?(submission), in_review?(submission)]
      )
    end

    def task_month_and_year(task)
      "#{Date::MONTHNAMES[task.period_month]} #{task.period_year}"
    end

    def task_name(submission)
      task = submission.task
      "#{task.framework.short_name} - #{task.framework.name} - #{task_month_and_year(task)}"
    end

    def validation_failed?(submission)
      submission.aasm_state.to_s == 'validation_failed' ? 'y' : 'n'
    end

    def ingest_failed?(submission)
      submission.aasm_state.to_s == 'ingest_failed' ? 'y' : 'n'
    end

    def in_review?(submission)
      submission.aasm_state.to_s == 'in_review' ? 'y' : 'n'
    end

    def suppliers
      Supplier.includes(:active_users, :submissions).joins(:submissions).merge(unfinished_submissions).distinct
    end

    def unfinished_submissions
      @unfinished_submissions ||= Submission.where(aasm_state: UNFINISHED_STATUSES)
    end
  end
end

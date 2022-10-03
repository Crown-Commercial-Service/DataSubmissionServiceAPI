require 'csv'
require 'notifications/client'

class Task
  # Used to generate either an 'unfinished' CSV for all users
  # of suppliers with unfinished submissions, due to ingest
  # or validation failure, or still being in review, or call
  # GOV.UK Notify API, generating emails for the above.

  # Outputs via +puts+ objects that respond_to? it
  # (+STDOUT+ or +File+ being usual)

  class UnfinishedUserNotificationList
    UNFINISHED_STATUSES = ['validation_failed', 'ingest_failed', 'in_review'].freeze
    HEADER = ['email address', 'task_period', 'person_name', 'supplier_name', 'task_name', 'submission_date'] + UNFINISHED_STATUSES.freeze

    attr_reader :logger, :output

    def initialize(output: $stdout, logger: Rails.logger)
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def generate
      logger.info 'Generating contacts with unfinished submissions.'

      output.puts(CSV.generate_line(HEADER))

      tasks_with_unfinished_submissions.each do |task|
        task.supplier.active_users.each do |user|
          output.puts csv_line_for(user, task.supplier, task.latest_submission, task)
        end
      end
    end

    def notify
      logger.info 'Emailing contacts with unfinished submissions.'

      tasks_with_unfinished_submissions.each do |task|
        task.supplier.active_users.each do |user|
          submission = task.latest_submission
          notify_client.send_email(
            email_address: user.email,
            template_id: '3434c9dd-af04-490a-b53a-e7600a09aa4d',
            email_reply_to_id: "9f7dd112-885c-4d09-bcf7-65f44268c05d",
            personalisation: {
              person_name: user.name,
              supplier_name: task.supplier.name,
              task_name: task_name(task),
              task_period: task_month_and_year(task),
              submission_date: submission_date(submission),
              ingest_failed: ingest_failed?(submission),
              validation_failed: validation_failed?(submission),
              in_review: in_review?(submission)
            }
          )
        end
      end
    end

    private

    def notify_client
      @notify_client ||= Notifications::Client.new(ENV['NOTIFY_API_KEY'])
    end

    def csv_line_for(user, supplier, submission, task)
      CSV.generate_line(
        [user.email, task_month_and_year(task), user.name, supplier.name, task_name(task), submission_date(submission), validation_failed?(submission), ingest_failed?(submission), in_review?(submission)]
      )
    end

    def task_month_and_year(task)
      "#{Date::MONTHNAMES[task.period_month]} #{task.period_year}"
    end

    def task_name(task)
      "#{task.framework.short_name} - #{task.framework.name} - #{task_month_and_year(task)}"
    end

    def submission_date(submission)
      submission.updated_at.strftime('%d/%m/%Y')
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

    def unfinished_submissions_relation
      @unfinished_submissions_relation ||= Submission.where(aasm_state: UNFINISHED_STATUSES)
    end

    def tasks_with_unfinished_submissions
      Task.incomplete.includes(:submissions).joins(:submissions).merge(unfinished_submissions_relation)
    end
  end
end

class Task
  class UnfinishedUserNotifications
    include Enumerable

    UNFINISHED_STATUSES = %w[
      validation_failed
      ingest_failed
      in_review
    ].freeze

    def each
      return enum_for(:each) unless block_given?

      tasks_with_unfinished_submissions.find_each do |task|
        supplier = task.supplier
        submission = task.latest_submission

        supplier.active_users.each do |user|
          yield (
            {
              email: user.email,
              supplier_name: supplier.name,
              personalisation: {
                task_period: task_period(task),
                person_name: user.name,
                supplier_name: supplier.name,
                task_name: task_name(task),
                submission_date: submission_date(submission),
                validation_failed: status_flag(submission, 'validation_failed'),
                ingest_failed: status_flag(submission, 'ingest_failed'),
                in_review: status_flag(submission, 'in_review')
              }
            }
          )
        end
      end
    end

    private

    def task_period(task)
      "#{Date::MONTHNAMES[task.period_month]} #{task.period_year}"
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

    def status_flag(submission, status)
      submission.aasm_state.to_s == status ? 'y' : 'n'
    end

    def unfinished_submissions_relation
      Submission.where(aasm_state: UNFINISHED_STATUSES)
    end

    def tasks_with_unfinished_submissions
      Task.incomplete
          .includes(:submissions, :supplier, :framework)
          .joins(:submissions)
          .merge(unfinished_submissions_relation)
          .distinct
    end
  end
end

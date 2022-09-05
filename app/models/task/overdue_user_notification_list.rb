require 'notifications/client'

class Task
  # Used to call GOV.UK Notify API and generate emails
  # for all users of suppliers with incomplete submissions
  # in the given year/month period.

  # Outputs via +puts+ objects that respond_to? it
  # (+STDOUT+ or +File+ being usual)

  class OverdueUserNotificationList
    attr_reader :logger, :output, :month, :year, :template_id

    def initialize(month:, year:, template_id:, output: $stdout, logger: Rails.logger)
      @month = month
      @year = year
      @template_id = template_id
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def notify
      logger.info "Emailing late contacts for #{year}, #{month}"

      suppliers.each do |supplier|
        supplier.active_users.each do |user|
          notify_client.send_email(
            email_address: user.email,
            template_id: template_id,
            personalisation: {
              person_name: user.name,
              supplier_name: supplier.name,
              framework: frameworks_for(supplier),
              reporting_month: reporting_month,
              due_date: due_date
            }
          )
        end
      end
    end

    private

    def notify_client
      @notify_client ||= Notifications::Client.new(ENV['NOTIFY_API_KEY'])
    end

    def reporting_month
      @reporting_month ||= [Date::MONTHNAMES[month], year].join(' ')
    end

    def due_date
      @due_date ||= SubmissionWindow.new(year, month).due_date.to_s(:day_month_year)
    end

    def framework_count
      @framework_count ||= suppliers.map { |supplier| supplier.tasks.pluck(:framework_id).uniq.size }.max || 0
    end

    def frameworks_for(supplier)
      frameworks_with_incomplete_tasks = supplier.tasks
                                                 .map { |task| "#{task.framework.short_name} - #{task.framework.name}" }
                                                 .sort

      frameworks_with_incomplete_tasks.fill(nil, frameworks_with_incomplete_tasks.size...framework_count)
    end

    def suppliers
      Supplier.includes(:active_users, :tasks).joins(:tasks).merge(incomplete_tasks_relation).distinct
    end

    def incomplete_tasks_relation
      @incomplete_tasks_relation ||= Task.where(period_month: month, period_year: year).incomplete
    end
  end
end

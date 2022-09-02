require 'notifications/client'

class Task
  # Used to call GOV.UK Notify API and generate emails
  # for all users that are expected to have monthly tasks
  # in the given year/month period.
  #
  # Outputs via +puts+ objects that respond_to? it (+STDOUT+ or
  # +File+ being usual)

  class AnticipatedUserNotificationList
    attr_reader :logger, :output, :month, :year, :template_id

    def initialize(month:, year:, output: $stdout, logger: Rails.logger)
      @month = month
      @year = year
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def notify
      logger.info "Emailing contacts with tasks for #{year}, #{month}"

      suppliers.find_each do |supplier|
        next if supplier.active_frameworks.empty?

        supplier.active_users.each do |user|
          notify_client.send_email(
            email_address: user.email,
            template_id: 'c67cd90d-e0d9-4d6e-bc4d-68ef5e20d2e4',
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
      @framework_count ||= suppliers.map { |supplier| supplier.active_frameworks.ids.uniq.size }.max || 0
    end

    def frameworks_for(supplier)
      framework_names = supplier.active_frameworks
                                .map { |framework| "#{framework.short_name} - #{framework.name}" }
                                .sort

      framework_names.fill(nil, framework_names.size...framework_count)
    end

    def suppliers
      Supplier.includes(:active_users, :active_frameworks)
    end
  end
end

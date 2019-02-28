require 'csv'

class Task
  # Used to generate CSV for all users that are expected to have
  # monthly tasks in the given year/month period. The CSV is
  # expected to be fed into GOV.UK Notify so emails can be
  # scheduled to go out the day the tasks are generated.
  #
  # Outputs via +puts+ objects that respond_to? it (+STDOUT+ or
  # +File+ being usual)
  class AnticipatedUserNotificationList
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

      output.puts(CSV.generate_line(HEADER))

      suppliers.find_each do |supplier|
        supplier.users.each do |user|
          output.puts(
            CSV.generate_line(
              [
                user.email,
                due_date,
                user.name,
                supplier.name,
                reporting_month
              ]
            )
          )
        end
      end
    end

    private

    def reporting_month
      [Date::MONTHNAMES[month], year].join(' ')
    end

    def due_date
      'DUE_DATE?'
    end

    def suppliers
      Supplier.joins(:agreements).merge(Agreement.active)
    end
  end
end

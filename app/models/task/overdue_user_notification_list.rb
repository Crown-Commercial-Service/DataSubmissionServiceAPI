require 'csv'

class Task
  # Used to generate a 'late' CSV for all users
  # of suppliers with incomplete submissions in the
  # given year/month period. Outputs via +puts+ objects
  # that respond_to? it (+STDOUT+ or +File+ being usual)
  class OverdueUserNotificationList
    HEADER = [
      'User Name',
      'Email Address',
      'Framework Number'
    ].freeze

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
      user_framework_lates.find_each do |user_framework|
        output.puts(
          CSV.generate_line(
            [
              user_framework.user_name,
              user_framework.user_email,
              user_framework.framework_short_name
            ]
          )
        )
      end
    end

    private

    ##
    # NB should become its own class if this becomes an
    # admin front end confection. This class should be concerned
    # with generating CSV, not getting the records
    def user_framework_lates
      Task
        .incomplete
        .where(period_month: month, period_year: year)
        .select('
          tasks.id,
          frameworks.short_name AS framework_short_name,
          users.name AS user_name,
          users.email AS user_email
        ')
        .joins(
          :framework,
          supplier: { memberships: :user }
        )
    end
  end
end

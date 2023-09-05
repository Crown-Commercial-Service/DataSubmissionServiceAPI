require 'csv'

module Offboard
  class DeactivateUsers
    DEFAULT_WAIT = 0.2
    EXPECTED_HEADERS = %I[email].freeze

    attr_reader :logger, :wait_time

    def initialize(csv_path, wait_time: DEFAULT_WAIT, logger: Logger.new($stdout))
      @csv = CSV.read(csv_path, headers: true, header_converters: :symbol)
      @logger = logger
      @wait_time = wait_time
      verify_csv_headers!
    end

    def run
      ActiveRecord::Base.transaction do
        @csv.each do |row_data|
          user = User.find_by(email: row_data[:email])
          raise ActiveRecord::RecordNotFound, "Couldn\'t find user with email address: #{row_data[:email]}" if user.nil?

          DeactivateUser.new(user: user).call
          log "User #{user.name} is deactivated"
          wait
        end
      end
    end

    private

    def wait
      sleep(wait_time)
    end

    def log(message)
      logger.info message
    end

    def verify_csv_headers!
      raise ArgumentError, "Missing headers in CSV file: #{missing_headers.to_sentence}" if missing_headers.any?
    end

    def missing_headers
      EXPECTED_HEADERS - @csv.headers
    end
  end
end

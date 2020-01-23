require 'csv'

# Performs a bulk import of users to RMI
#
# Pass in a path to a CSV file with the following headers:
#
#   email - the email address of the user
#   name - the full name of the user
#   supplier_salesforce_id - the Salesforce ID for the user's supplier
#
# New users are added to RMI, added to Auth0, and associated with the supplier
# matching the supplier_salesforce_id. If the user already exists, the existing
# user will be associated with the supplier, but only if it isn't already
# associated, making running the import idempotent.
#
# The import process pauses 0.2 seconds between each user so as not to trigger
# the Auth0 rate limiting. This can be overridden by passing in the optional
# named parameter `wait_time`.
#
# Example:
#
#   Import::Users.new('/tmp/new_users.csv').run
#
# Note: when running this on a docker container you will need to copy the CSV
# file into the container itself. Use the `docker cp` command to do this.
module Import
  class Users
    class InvalidSalesforceId < StandardError; end

    DEFAULT_WAIT = 0.2
    EXPECTED_HEADERS = %I[supplier_salesforce_id email name].freeze

    attr_reader :logger, :wait_time

    def initialize(csv_path, wait_time: DEFAULT_WAIT, logger: Logger.new(STDOUT))
      @csv_path = csv_path
      @csv = CSV.read(csv_path, headers: true, header_converters: :symbol)
      @logger = logger
      @wait_time = wait_time
      verify_csv_headers!
    end

    def run
      check_for_missing_salesforce_ids

      ActiveRecord::Base.transaction do
        @csv.each do |row_data|
          user = Row.new(row_data).import!
          log "User #{user.email} is associated with #{user.suppliers.map(&:name).to_sentence}"
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

    def check_for_missing_salesforce_ids
      supplier_salesforce_ids = Supplier.pluck(:salesforce_id, 1).to_h

      @csv.each do |row_data|
        salesforce_id = row_data[:supplier_salesforce_id]
        next if supplier_salesforce_ids.key?(salesforce_id)

        raise InvalidSalesforceId, "Could not find a supplier with salesforce_id '#{salesforce_id}'."
      end
    end
  end
end

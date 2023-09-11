require 'csv'

# Performs a bulk off-board of suppliers from a framework
#
# Pass in a path to a CSV file with the following headers:
#
#   framework_short_name  - the short identifier for the framework, e.g. 'RM606'
#   supplier_name         - the name of the supplier
#   salesforce_id         - the Salesforce ID for the supplier
#
# For each row in the CSV, the following will happen:
#
#   - the supplier will be off-boarded from the specified framework
#
# Example:
#
#   Offboard::DeactivateSuppliers.new('/tmp/framework_suppliers.csv').run
#
module Offboard
  class DeactivateSuppliers
    EXPECTED_HEADERS = %I[framework_short_name supplier_name salesforce_id].freeze

    attr_reader :logger, :wait_time

    def initialize(csv_path, logger: Logger.new($stdout))
      @csv = CSV.read(csv_path, headers: true, header_converters: :symbol)
      @logger = logger
      verify_csv_headers!
    end

    def run
      ActiveRecord::Base.transaction do
        @csv.each do |row_data|
          Row.new(**row_data).offboard!
          log "Supplier #{row_data.fetch(:supplier_name)} removed from framework \
          #{row_data.fetch(:framework_short_name)} "
        end
      end
    end

    private

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

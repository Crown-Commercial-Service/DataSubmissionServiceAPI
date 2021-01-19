require 'csv'

# Performs a bulk on-board of suppliers to a framework
#
# Pass in a path to a CSV file with the following headers:
#
#   framework_short_name  - the short identifier for the framework, e.g. 'RM606'
#   lot_number            - the lot number the supplier should have access to
#   supplier_name         - the name of the supplier
#   salesforce_id         - the Salesforce ID for the supplier
#
# For each row in the CSV, the following will happen:
#
#   - the supplier will be added to RMI if it does not exist already
#   - an agreement linking the supplier to the framework will be created,
#     unless one exists already
#   - the lot number will be added to the supplier agreement, unless it exists
#     already
#
# Example:
#
#   Onboard::FrameworkSuppliers.new('/tmp/new_framework_suppliers.csv').run
#
module Onboard
  class FrameworkSuppliers
    EXPECTED_HEADERS = %I[framework_short_name lot_number supplier_name salesforce_id].freeze

    attr_reader :logger, :wait_time

    def initialize(csv_path, logger: Logger.new(STDOUT))
      @csv = CSV.read(csv_path, headers: true, header_converters: :symbol)
      @logger = logger
      verify_csv_headers!
    end

    def run
      ActiveRecord::Base.transaction do
        @csv.each do |row_data|
          Row.new(row_data).onboard!
          log "Supplier #{row_data.fetch(:supplier_name)} added to Lot #{row_data.fetch(:lot_number)} " \
              "on #{row_data.fetch(:framework_short_name)}"
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

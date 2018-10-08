require 'csv'

class Framework
  ##
  # Operating on a fixed CSV file data/framework_miso_fields.csv,
  # provide a means for getting the framework name and invoice and
  # order fields for the framework short name given to +initialize+
  class MisoFields
    FILENAME = Rails.root.join('data', 'framework_miso_fields.csv').freeze

    attr_reader :framework_short_name
    def initialize(framework_short_name)
      @framework_short_name = framework_short_name
    end

    def framework_name
      framework_fields.first['Name']
    end

    def invoice_fields
      @invoice_fields ||= framework_fields.select { |row| row['DestinationTable'] == 'Invoices' }
    end

    def invoice_total_value_field
      row = invoice_fields.find { |f| f['ExportsTo'] == 'InvoiceValue' } or
        raise ArgumentError, "no InvoiceValue field found for framework '#{framework_short_name}'"
      row['DisplayName']
    end

    def order_total_value_field
      row = order_fields.find { |f| f['ExportsTo'] == 'ContractValue' } or
        raise ArgumentError, "no ContractValue field found for framework '#{framework_short_name}'"
      row['DisplayName']
    end

    def order_fields
      @order_fields ||= framework_fields.select { |row| row['DestinationTable'] == 'Orders' }
    end

    private

    def source_csv
      @source_csv ||= CSV.read(FILENAME, headers: true)
    end

    def framework_fields
      @framework_fields ||= source_csv.select { |row| row['FrameworkNumber'] == framework_short_name }.tap do |fields|
        raise ArgumentError, "No fields for framework #{framework_short_name} found in #{FILENAME}" if fields.empty?
      end
    end
  end
end

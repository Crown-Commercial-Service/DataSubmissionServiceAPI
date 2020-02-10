module Ingest
  class Loader
    class MissingInvoiceColumns < StandardError; end
    class MissingOrderColumns < StandardError; end

    ##
    # Given a +converter+ (result of Ingest::Converter) and +submission_file+,
    # validate and load the rows for invoices and orders into the database
    #
    # Passing +persist+ as false results in the generated submission entries
    # being written to a YML file for debugging purposes. No changes are made
    # to the database
    def initialize(converter, submission_file, persist = true)
      @converter = converter
      @submission_file = submission_file
      @framework = submission.framework
      @definition = @framework.definition
      @persist = persist

      @urns = Customer.pluck(:urn, 1).to_h
    end

    def perform
      @submission_file.update!(rows: @converter.rows) if @persist

      determine_correct_framework_used

      load_invoices
      load_orders
      load_others
    end

    private

    def load_invoices
      return if @converter.invoices.row_count.zero?

      Rails.logger.info "Loading #{@converter.invoices.row_count} invoice rows"

      sheet_definition = @definition.for_entry_type('invoice')

      load_data_from(@converter.invoices, sheet_definition) do |invoice_total|
        submission.update!(invoice_total: invoice_total)
      end
    end

    def load_orders
      return if @converter.orders.row_count.zero?

      Rails.logger.info "Loading #{@converter.orders.row_count} order rows"

      sheet_definition = @definition.for_entry_type('order')
      load_data_from(@converter.orders, sheet_definition)
    end

    def load_others
      return if @converter.others.row_count.zero?

      Rails.logger.info "Loading #{@converter.others.row_count} other rows"

      sheet_definition = @definition.for_entry_type('other')
      load_data_from(@converter.others, sheet_definition)
    end

    def determine_correct_framework_used
      invoice_diff = invoice_attributes.difference(invoice_headers)
      order_diff   = order_attributes.difference(order_headers)

      raise MissingInvoiceColumns, invoice_diff.to_a.to_sentence unless invoice_diff.empty? || invoice_headers.empty?
      raise MissingOrderColumns, order_diff.to_a.to_sentence unless order_diff.empty? || order_headers.empty?
    end

    # rubocop:disable Metrics/AbcSize
    #
    # Load data from given rows and yield the running total from
    # within the final persist transaction
    def load_data_from(rows, sheet_definition)
      entries = []
      running_total = 0
      process_csv_row = ProcessCsvRow.new(sheet_definition)

      rows.data.each do |row|
        entry = SubmissionEntry.new(
          submission_file: @submission_file,
          submission: submission,
          entry_type: rows.type,
          source: {
            row: Integer(row['line_number']) + 1,
            sheet: rows.sheet_name
          },
          data: process_csv_row.process(row)
        )

        next if entry.data.values.map { |v| v.to_s.strip }.all?(&:blank?) # Skip empty rows

        entry.customer_urn = entry.data.dig(sheet_definition.export_mappings['CustomerURN'])
        entry.customer_urn = nil unless @urns.key?(entry.customer_urn)

        entry.total_value = entry.data.dig(sheet_definition.total_value_field)

        entry.validate_against!(sheet_definition)

        running_total += entry.total_value || 0
        entries << entry
      end

      if @persist
        SubmissionEntry.transaction do
          SubmissionEntry.import(entries, batch_size: 500, validate: false)
          yield running_total if block_given?
        end
      else
        File.open("/tmp/ingest_#{@submission_file.id}_#{rows.type}.yml", 'w') do |f|
          f.write entries.to_yaml
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def submission
      @submission_file.submission
    end

    def invoice_attributes
      Set.new(@definition.attributes_for_entry_type('invoice'))
    end

    def order_attributes
      Set.new(@definition.attributes_for_entry_type('order'))
    end

    def invoice_headers
      Set.new(@converter.invoices.data.first.to_h.keys - ['line_number'])
    end

    def order_headers
      Set.new(@converter.orders.data.first.to_h.keys - ['line_number'])
    end
  end
end

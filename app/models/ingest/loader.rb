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
      @framework = @submission_file.submission.framework
      @definition = @framework.definition
      @persist = persist

      @urns = Customer.pluck(:urn, 1).to_h
    end

    def perform
      @submission_file.update!(rows: @converter.rows) if @persist

      determine_correct_framework_used

      load_invoices
      load_orders
    end

    private

    def load_invoices
      return if @converter.invoices.row_count.zero?

      Rails.logger.info "Loading #{@converter.invoices.row_count} invoice rows"

      sheet_definition = @definition.for_entry_type('invoice')
      load_data_from(@converter.invoices, sheet_definition)
    end

    def load_orders
      return if @converter.orders.row_count.zero?

      Rails.logger.info "Loading #{@converter.orders.row_count} order rows"

      sheet_definition = @definition.for_entry_type('order')
      load_data_from(@converter.orders, sheet_definition)
    end

    def determine_correct_framework_used
      invoice_diff = invoice_attributes.difference(invoice_headers)
      order_diff   = order_attributes.difference(order_headers)

      raise MissingInvoiceColumns, invoice_diff.to_a.to_sentence unless invoice_diff.empty? || invoice_headers.empty?
      raise MissingOrderColumns, order_diff.to_a.to_sentence unless order_diff.empty? || order_headers.empty?
    end

    # rubocop:disable Metrics/AbcSize
    def load_data_from(rows, sheet_definition)
      entries = []
      process_csv_row = ProcessCsvRow.new(sheet_definition)

      rows.data.each do |row|
        entry = SubmissionEntry.new(
          submission_file: @submission_file,
          submission: @submission_file.submission,
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

        entries << entry
      end

      if @persist
        SubmissionEntry.transaction do
          SubmissionEntry.import(entries, batch_size: 500, validate: false)
        end
      else
        File.open("/tmp/ingest_#{@submission_file.id}_#{rows.type}.yml", 'w') do |f|
          f.write entries.to_yaml
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

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

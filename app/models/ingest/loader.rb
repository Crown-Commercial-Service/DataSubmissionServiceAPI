module Ingest
  class Loader
    class MissingColumns < StandardError
      attr_accessor :entry_type
      def initialize(entry_type, missing_columns)
        super("Column(s) missing for #{entry_type}: #{missing_columns}")
        self.entry_type = entry_type
      end
    end

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

      raise_when_columns_missing

      load_entries('invoice') do |total|
        submission.update!(invoice_total: total)
      end
      load_entries('order')
      load_entries('other')
    end

    private

    def load_entries(entry_type)
      rows = @converter.rows_for(entry_type)
      return if rows.row_count.zero?

      Rails.logger.info "Loading #{rows.row_count} #{entry_type} rows"

      sheet_definition = @definition.for_entry_type(entry_type)

      load_data_from(rows, sheet_definition) do |total|
        yield total if block_given?
      end
    end

    def raise_when_columns_missing
      SubmissionEntry::TYPES.each do |entry_type|
        headers = headers_for(entry_type)
        next if headers.empty?

        attributes = attributes_for(entry_type)

        diff = attributes.difference(headers)
        next if diff.empty?

        raise MissingColumns.new(entry_type, diff.to_a.to_sentence)
      end
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

    def attributes_for(entry_type)
      Set.new(@definition.attributes_for_entry_type(entry_type))
    end

    def headers_for(entry_type)
      Set.new(@converter.rows_for(entry_type).data.first.to_h.keys - ['line_number'])
    end
  end
end

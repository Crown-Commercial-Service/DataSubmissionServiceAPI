module Ingest
  class Loader
    ##
    # Given a +row+ and the relevant +sheet_definition+ (the sheet-specific
    # framework definition) coerce the data into the correct datatypes:
    #
    # - Dates are changed from ISO8601 to dd/mm/yyyy format
    # - Boolean 'True' and 'False' are changed to 'Y' and 'N'
    # - Decimals are truncated to deal with binary rounding errors
    #
    # It also strips out attributes that do not exist in the +sheet_definition+
    class ProcessCsvRow
      attr_reader :sheet_definition

      def initialize(sheet_definition)
        @sheet_definition = sheet_definition
      end

      def process(row)
        row = row.to_h.slice(*fields).compact
        row = strip_whitespace_from_strings(row)
        row = convert_date_fields(row)
        row = fix_booleans_in_numeric_fields(row)
        row = fix_booleans_in_other_fields(row)
        convert_numbers(row)
      end

      private

      def strip_whitespace_from_strings(row)
        row.each do |field, value|
          row[field].strip! if value.is_a?(String)
        end
      end

      def convert_date_fields(row)
        date_fields.each do |field|
          next if row[field].blank?

          row[field] = Date.parse(row[field]).strftime('%d/%m/%Y') if valid_date?(row[field])
          row[field] = (Date.new(1899, 12, 30) + row[field].to_i.days).strftime('%d/%m/%Y') if valid_float?(row[field])
        end

        row
      end

      def fix_booleans_in_numeric_fields(row)
        numeric_fields.each do |field|
          next unless row[field].is_a?(String)

          row[field] = 1 if row[field] == 'True'
          row[field] = 0 if row[field] == 'False'
        end

        row
      end

      def fix_booleans_in_other_fields(row)
        row.each do |field, value|
          next if numeric_fields.include?(field)
          next unless value.is_a?(String)

          row[field] = 'Y' if value == 'True'
          row[field] = 'N' if value == 'False'
        end
      end

      def convert_numbers(row)
        row.each do |field, value|
          row[field] = convert_number(value) if valid_float?(value)
        end
      end

      def valid_float?(value)
        # rubocop:disable AllCops
        return false if value.match?(/E/)
        # rubocop:enable AllCops
        !!Float(value)
      rescue ArgumentError
        false
      end

      def valid_date?(value)
        !!Date.iso8601(value) && value.match(/\d{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])/)
      rescue ArgumentError
        false
      end

      def convert_number(value)
        decimal = BigDecimal(value, 10).round(10)
        return Integer(decimal) if (decimal % 1).zero?

        Float(decimal)
      end

      def fields
        @fields ||= sheet_definition.attribute_types.keys
      end

      def date_fields
        @date_fields ||= sheet_definition
                         .validators
                         .select { |validator| validator.is_a?(IngestedDateValidator) }
                         .flat_map(&:attributes)
      end

      def numeric_fields
        @numeric_fields ||= sheet_definition
                            .validators
                            .select { |validator| validator.is_a?(ActiveModel::Validations::NumericalityValidator) }
                            .flat_map(&:attributes)
      end
    end
  end
end

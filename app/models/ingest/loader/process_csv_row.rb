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

        row.each do |field, value|
          row[field].strip! if value.is_a?(String)
        end

        date_fields.each do |field|
          next if row[field].blank?
          next unless row[field].match?(/\d{4}-\d{2}-\d{2}/)

          row[field] = Date.parse(row[field]).strftime('%d/%m/%Y')
        end

        row.each do |key, value|
          converted_value = if valid_float?(value)
                              convert_number(value)
                            elsif value == 'True'
                              'Y'
                            elsif value == 'False'
                              'N'
                            else
                              value
                            end

          row[key] = converted_value
        end
      end

      private

      def valid_float?(value)
        !!Float(value)
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
    end
  end
end

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

          row[field] = Date.parse(row[field]).strftime('%d/%m/%Y') if row[field].match?(/\d{4}-\d{2}-\d{2}/)
          row[field] = (Date.new(1899, 12, 30) + row[field].to_i.days).strftime('%d/%m/%Y') if valid_float?(row[field])
        end

        numeric_fields.each do |field|
          next if row[field].nil?

          row[field] = if valid_float?(row[field])
                         convert_number(row[field])
                       elsif row[field] == 'True'
                         1
                       elsif row[field] == 'False'
                         0
                       else
                         row[field]
                       end
        end

        row.each do |field, value|
          next if value.blank? || date_fields.include?(field) || numeric_fields.include?(field)

          if valid_float?(value)
            row[field] = convert_number(value)
          elsif value == 'True'
            row[field] = 'Y'
          elsif value == 'False'
            row[field] = 'N'
          end
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

      def numeric_fields
        @numeric_fields ||= sheet_definition
                            .validators
                            .select { |validator| validator.is_a?(IngestedNumericalityValidator) }
                            .flat_map(&:attributes)
      end
    end
  end
end

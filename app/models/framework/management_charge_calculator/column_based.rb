class Framework
  module ManagementChargeCalculator
    class ColumnBased
      attr_reader :varies_by, :value_to_percentage

      def initialize(varies_by:, value_to_percentage:)
        @varies_by = varies_by
        @value_to_percentage = normalise_hash(value_to_percentage)
      end

      def calculate_for(entry)
        @percentage_details = percentage_details_for(column_values_for(entry))

        if @percentage_details.nil?
          Rollbar.error(
            "Got value '#{column_values_for(entry)}' for '#{varies_by}' on #{entry.framework.short_name}"\
            "from entry #{entry.id}. Missing validation?"
          )

          return 0.0
        end

        (source_value(entry) * (BigDecimal(@percentage_details[:percentage]) / 100)).truncate(4)
      end

      private

      def source_value(entry)
        if @percentage_details[:column] && @percentage_details[:column].is_a?(Array)
          @percentage_details[:column].map { |column| entry.data[column] }.reduce(:+)
        elsif @percentage_details[:column]
          entry.data[@percentage_details[:column]]
        else
          entry.total_value
        end
      end

      def column_values_for(entry)
        Array(varies_by).map { |column| entry.data[column].to_s.downcase }
      end

      # Downcase keys
      def normalise_hash(hash)
        hash.transform_keys do |values|
          Array(values).map { |value| value.to_s.downcase }
        end
      end

      def percentage_details_for(column_names_for_entry)
        percentage_details = value_to_percentage[column_names_for_entry]
        return percentage_details unless percentage_details.nil?

        # Fallback to the most relevant wildcard lookup
        column_count = column_names_for_entry.size

        column_count.downto(0) do |position|
          column_names_with_wildcards = column_names_for_entry.fill('*', position)
          percentage_details ||= value_to_percentage[column_names_with_wildcards]
        end

        percentage_details
      end
    end
  end
end

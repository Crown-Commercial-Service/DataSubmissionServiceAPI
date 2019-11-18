class Framework
  module ManagementChargeCalculator
    class ColumnBased
      attr_reader :varies_by, :value_to_percentage

      def initialize(varies_by:, value_to_percentage:)
        @varies_by = varies_by
        @value_to_percentage = prepare_hash(value_to_percentage)
      end

      def calculate_for(entry)
        column_names_for_entry = Array(varies_by).map { |column| entry.data.dig(column).downcase }
        percentage = percentage_for(column_names_for_entry)

        if percentage.nil?
          Rollbar.error(
            "Got value '#{column_names_for_entry}' for '#{varies_by}' on #{entry.framework.short_name}"\
            "from entry #{entry.id}. Missing validation?"
          )

          return 0.0
        end

        (entry.total_value * (percentage / 100)).truncate(4)
      end

      private

      def prepare_hash(hash)
        hash.deep_transform_keys(&:downcase).with_indifferent_access
      end

      def percentage_for(column_names_for_entry)
        column_count = column_names_for_entry.size
        percentage = nil

        # Fallback to the most relevant wildcard lookup
        (column_count + 1).downto(0) do |position|
          column_names_with_wildcards = column_names_for_entry.fill('*', position)
          percentage ||= value_to_percentage.dig(*column_names_with_wildcards)
        end

        percentage
      end
    end
  end
end

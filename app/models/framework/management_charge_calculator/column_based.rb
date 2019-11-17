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
        percentage = value_to_percentage.dig(*column_names_for_entry)

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
    end
  end
end

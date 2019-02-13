class Framework
  module ManagementChargeCalculator
    class ColumnBased
      attr_reader :column, :value_to_percentage

      def initialize(column:, value_to_percentage:)
        @column = column
        @value_to_percentage = prepare_hash(value_to_percentage)
      end

      def calculate_for(entry)
        column_value_for_entry = entry.data.dig(column).to_s
        percentage = value_to_percentage[column_value_for_entry.downcase]

        if percentage.nil?
          Rollbar.error(
            "Got value '#{column_value_for_entry}' for '#{column}' on #{entry.framework.short_name}"\
            "from entry #{entry.id}. Missing validation?"
          )

          return 0.0
        end

        (entry.total_value * (percentage / 100)).truncate(4)
      end

      private

      def prepare_hash(hash)
        hash.map { |k, v| [k.to_s.downcase, v] }.to_h
      end
    end
  end
end

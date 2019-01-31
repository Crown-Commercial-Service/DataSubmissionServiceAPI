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

        (entry.total_value * (percentage / 100)).truncate(4)
      end

      private

      def prepare_hash(hash)
        hash.map { |k, v| [k.to_s.downcase, v] }.to_h
      end
    end
  end
end

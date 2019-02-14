class Framework
  module ManagementChargeCalculator
    class FlatRate
      attr_reader :percentage

      def initialize(percentage:)
        @percentage = BigDecimal(percentage)
      end

      def calculate_for(entry)
        (entry.total_value * (percentage / 100)).truncate(4)
      end
    end
  end
end

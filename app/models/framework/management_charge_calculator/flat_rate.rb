class Framework
  module ManagementChargeCalculator
    # Calculates flat-rate management charges.
    #
    # By default the calculation is made against the total_value of the
    # submission entry. For frameworks where the management charge needs to be
    # calculated against another column, that can be specified with the `column`
    # attribute.
    class FlatRate
      attr_reader :percentage, :column

      def initialize(percentage:, column: nil)
        @percentage = BigDecimal(percentage)
        @column = column
      end

      def calculate_for(entry)
        (entry_value(entry) * (percentage / 100)).truncate(4)
      end

      private

      def entry_value(entry)
        overridding_calculation_column? ? entry.data[@column].to_d : entry.total_value
      end

      def overridding_calculation_column?
        @column.present?
      end
    end
  end
end

module ActiveModel
  class Introspector
    class ManagementCharge
      attr_reader :calculator
      def initialize(calculator)
        @calculator = calculator
      end

      def to_fdl
        case calculator
        when Framework::ManagementChargeCalculator::FlatRate
          "ManagementCharge #{calculator.percentage}%"
        else
          'Nothing'
        end
      end
    end
  end
end



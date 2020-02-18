class Framework
  module ManagementChargeCalculator
    class SectorBased
      attr_reader :central_government, :wider_public_sector

      def initialize(central_government:, wider_public_sector:)
        @central_government = central_government
        @wider_public_sector = wider_public_sector
      end

      def calculate_for(entry)
        (entry.total_value * (percentage(entry) / 100)).truncate(4)
      end

      private

      def percentage(entry)
        urn = entry.customer_urn
        sector = Customer.select(:sector).find_by(urn: urn).sector
        BigDecimal(send(sector))
      end
    end
  end
end

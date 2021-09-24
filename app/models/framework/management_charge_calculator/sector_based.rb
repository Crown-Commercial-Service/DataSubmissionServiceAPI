class Framework
  module ManagementChargeCalculator
    class SectorBased
      attr_reader :central_government, :wider_public_sector

      def initialize(central_government:, wider_public_sector:)
        @central_government = central_government
        @wider_public_sector = wider_public_sector
      end

      def calculate_for(entry)
        sector = sector_for(entry)
        percentage = if sector[:percentage]
                       BigDecimal(sector[:percentage])
                     else
                       @varies_by = sector[:column_names]
                       @value_to_percentage = normalise_hash(sector[:value_to_percentage])
                       @percentage_details = percentage_details_for(column_values_for(entry))

                       if @percentage_details.nil?
                         Rollbar.error(
                           "Got value '#{column_values_for(entry)}' for '#{@varies_by}' on "\
                           "#{entry.framework.short_name} from entry #{entry.id}. Missing validation?"
                         )

                         return 0.0
                       end

                       BigDecimal(@percentage_details[:percentage])
                     end

        (source_value(entry) * (percentage / 100)).truncate(4)
      end

      private

      def sector_for(entry)
        urn = entry.customer_urn
        sector = Customer.select(:sector).find_by(urn: urn).sector
        sector == 'central_government' ? central_government : wider_public_sector
      end

      def source_value(entry)
        if @percentage_details && @percentage_details[:column]
          entry.data[@percentage_details[:column]]
        else
          entry.total_value
        end
      end

      def column_values_for(entry)
        Array(@varies_by).map { |column| entry.data[column].to_s.downcase }
      end

      def percentage_details_for(column_names_for_entry)
        percentage_details = @value_to_percentage[column_names_for_entry]
        return percentage_details unless percentage_details.nil?

        # Fallback to the most relevant wildcard lookup
        column_count = column_names_for_entry.size

        column_count.downto(0) do |position|
          column_names_with_wildcards = column_names_for_entry.fill('*', position)
          percentage_details ||= @value_to_percentage[column_names_with_wildcards]
        end

        percentage_details
      end

      # Downcase keys
      def normalise_hash(hash)
        hash.transform_keys do |values|
          Array(values).map { |value| value.to_s.downcase }
        end
      end
    end
  end
end

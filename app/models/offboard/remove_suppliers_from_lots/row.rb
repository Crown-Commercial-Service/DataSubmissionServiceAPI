module Offboard
  class RemoveSuppliersFromLots
    class Row
      attr_reader :supplier_name, :salesforce_id, :coda_reference, :framework_short_name, :lot_number

      def initialize(supplier_name:, salesforce_id:, coda_reference:, framework_short_name:, lot_number:)
        @supplier_name = supplier_name
        @salesforce_id = salesforce_id
        @coda_reference = coda_reference
        @framework_short_name = framework_short_name
        @lot_number = lot_number
      end

      def offboard!
        find_supplier.tap do |supplier|
          break unless supplier

          agreement = find_agreement(supplier)
          remove_agreement_framework_lot(agreement)
          agreement.deactivate! if no_lots_on_agreement?(agreement)
        end
      end

      private

      def framework
        @framework ||= Framework.published.find_by!(short_name: framework_short_name)
      end

      def framework_lot
        framework.lots.find_by!(number: lot_number)
      end

      def find_supplier
        Supplier.find_by(salesforce_id: salesforce_id)
      end

      def find_agreement(supplier)
        supplier.agreements.find_by!(framework: framework)
      end

      def remove_agreement_framework_lot(agreement)
        agreement.agreement_framework_lots.where(framework_lot: framework_lot).destroy_all
      end

      def no_lots_on_agreement?(agreement)
        agreement.agreement_framework_lots.empty?
      end
    end
  end
end

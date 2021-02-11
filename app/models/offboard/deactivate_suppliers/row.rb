module Offboard
  class DeactivateSuppliers
    class Row
      attr_reader :supplier_name, :salesforce_id, :framework_short_name

      def initialize(supplier_name:, salesforce_id:, framework_short_name:)
        @supplier_name = supplier_name
        @salesforce_id = salesforce_id
        @framework_short_name = framework_short_name
      end

      def offboard!
        find_supplier.tap do |supplier|
          break unless supplier

          agreement = find_agreement(supplier)
          agreement.deactivate!
        end
      end

      private

      def framework
        @framework ||= Framework.published.find_by!(short_name: framework_short_name)
      end

      def find_supplier
        Supplier.find_by(salesforce_id: salesforce_id)
      end

      def find_agreement(supplier)
        supplier.agreements.find_by!(framework: framework)
      end
    end
  end
end

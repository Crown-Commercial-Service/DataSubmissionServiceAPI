module Import
  class FrameworkSuppliers
    class Row
      attr_reader :supplier_name, :salesforce_id, :coda_reference, :framework_short_name, :lot_number

      def initialize(supplier_name:, salesforce_id:, coda_reference:, framework_short_name:, lot_number:)
        @supplier_name = supplier_name
        @salesforce_id = salesforce_id
        @coda_reference = coda_reference
        @framework_short_name = framework_short_name
        @lot_number = lot_number
      end

      def import!
        find_or_create_supplier.tap do |supplier|
          agreement = find_or_create_agreement(supplier)
          find_or_create_agreement_framework_lot(agreement)
        end
      end

      private

      def framework
        @framework ||= Framework.find_by!(short_name: framework_short_name)
      end

      def framework_lot
        framework.lots.find_by!(number: lot_number)
      end

      def find_or_create_supplier
        Supplier.find_or_create_by!(salesforce_id: salesforce_id) do |supplier|
          supplier.name = supplier_name
          supplier.coda_reference = coda_reference
        end
      end

      def find_or_create_agreement(supplier)
        supplier.agreements.find_or_create_by!(framework: framework)
      end

      def find_or_create_agreement_framework_lot(agreement)
        agreement.agreement_framework_lots.find_or_create_by!(framework_lot: framework_lot)
      end
    end
  end
end

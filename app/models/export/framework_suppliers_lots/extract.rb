module Export
  class FrameworkSuppliersLots
    module Extract
      def self.all_relevant(framework)
        AgreementFrameworkLot.select(
          <<~POSTGRESQL
            agreement_framework_lots.id     AS id,
            '#{framework.short_name}'::text AS _framework_reference,
            '#{framework.name}'::text       AS _framework_name,
            suppliers.name                  AS _supplier_name,
            suppliers.salesforce_id         AS _supplier_salesforce_id,
            agreements.active               AS _supplier_active,
            framework_lots.number           AS _lot_number
          POSTGRESQL
        ).joins(:framework_lot, agreement: :supplier).merge(FrameworkLot.where(framework_id: framework.id))
      end
    end
  end
end

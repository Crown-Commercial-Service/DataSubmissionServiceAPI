module Export
  class FrameworkSuppliersLots
    class Row < Export::CsvRow
      def row_values
        [
          model._framework_reference,
          model._framework_name,
          model._supplier_salesforce_id,
          model._supplier_name,
          supplier_active,
          model._lot_number,
        ]
      end

      def supplier_active
        model._supplier_active ? 'Y' : 'N'
      end
    end
  end
end

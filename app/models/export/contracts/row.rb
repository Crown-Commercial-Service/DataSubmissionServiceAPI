module Export
  class Contracts
    class Row < Export::CsvRow
      alias_method :contract, :model

      def row_values
        [
          contract.submission_id,
          value_for('CustomerURN'),
          value_for('CustomerName'),
          value_for('CustomerPostCode'),
          value_for('SupplierReferenceNumber'),
          value_for('CustomerReferenceNumber', default: nil),
          value_for('LotNumber'),
        ]
      end

      (1..8).each do |n|
        define_method "additional#{n}" do
          value_for("Additional#{n}", default: nil)
        end
      end

      private

      def value_for(destination_field, default: NOT_IN_DATA)
        source_field = Export::Template.source_field_for(
          destination_field,
          contract._framework_short_name
        )
        contract.data.fetch(source_field, default)
      end
    end
  end
end

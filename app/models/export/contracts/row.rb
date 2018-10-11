module Export
  class Contracts
    class Row < SubmissionEntryRow
      alias_method :contract, :model

      # rubocop:disable Metrics/AbcSize
      def row_values
        [
          contract.submission_id,
          value_for('CustomerURN'),
          value_for('CustomerName'),
          value_for('CustomerPostCode'),
          value_for('SupplierReferenceNumber'),
          value_for('CustomerReferenceNumber', default: nil),
          value_for('LotNumber'),
          value_for('ProductDescription', default: nil),
          value_for('ProductGroup', default: nil),
          value_for('ProductClass', default: nil),
          value_for('ProductSubClass', default: nil),
          value_for('ProductCode', default: nil),
          value_for('ProductLevel6', default: nil),
          value_for('CustomerContactName', default: nil),
          value_for('CustomerContactNumber', default: nil),
          value_for('CustomerContactEmail', default: nil),
          contract_start_date,
          contract_end_date,
          value_for('ContractValue'),
          value_for('ContractAwardChannel'),
          *values_for_additional
        ]
      end
      # rubocop:enable Metrics/AbcSize

      private

      def contract_start_date
        formatted_date value_for('ContractStartDate', default: nil)
      end

      def contract_end_date
        formatted_date value_for('ContractEndDate', default: nil)
      end
    end
  end
end

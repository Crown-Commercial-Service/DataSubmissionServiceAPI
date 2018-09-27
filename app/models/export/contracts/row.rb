module Export
  class Contracts
    class Row < SubmissionEntryRow
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
    end
  end
end

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
          value_for('ProductDescription', default: MISSING),
          value_for('ProductGroup', default: MISSING),
          value_for('ProductClass', default: MISSING),
          value_for('ProductSubClass', default: MISSING),
          value_for('ProductCode', default: MISSING),
          value_for('ProductLevel6', default: MISSING),
          value_for('CustomerContactName', default: MISSING),
          value_for('CustomerContactNumber', default: MISSING),
          value_for('CustomerContactEmail', default: MISSING),
          value_for('ContractStartDate'),
          value_for('ContractEndDate'),
        ]
      end
    end
  end
end

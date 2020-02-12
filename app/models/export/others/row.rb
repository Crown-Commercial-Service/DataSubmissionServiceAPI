module Export
  class Others
    class Row < SubmissionEntryRow
      alias_method :other, :model

      def row_values
        [
          other.submission.id,
          value_for('CustomerURN'),
          value_for('CustomerName'),
          value_for('SupplierReferenceNumber', default: nil),
          value_for('CustomerReferenceNumber', default: nil),
          value_for('LotNumber', default: nil),
          value_for('ProductDescription', default: nil),
          value_for('ProductGroup', default: nil),
          value_for('ProductClass', default: nil),
          value_for('ProductSubClass', default: nil),
          value_for('ProductCode', default: nil),
          *values_for_additional
        ]
      end
    end
  end
end

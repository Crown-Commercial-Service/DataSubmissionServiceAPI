module Export
  class Invoices
    class Row < SubmissionEntryRow
      alias_method :invoice, :model

      # rubocop:disable Metrics/AbcSize
      def row_values
        [
          invoice.submission_id,
          value_for('CustomerURN'),
          value_for('CustomerName'),
          value_for('CustomerPostCode'),
          value_for('InvoiceDate'),
          value_for('InvoiceNumber'),
          value_for('SupplierReferenceNumber'),
          value_for('Customer Reference Number', default: nil),
          value_for('LotNumber'),
          value_for('ProductDescription', default: nil),
          value_for('ProductGroup', default: nil),
          value_for('ProductClass', default: nil),
          value_for('ProductSubClass', default: nil),
          value_for('ProductCode', default: nil),
          value_for('UnitType'),
          value_for('UnitPrice'),
          value_for('UnitQuantity'),
          value_for('InvoiceValue'),
          value_for('Expenses', default: nil),
          value_for('VATCharged'),
          value_for('PromotionCode', default: nil),
          *values_for_additional
        ]
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end

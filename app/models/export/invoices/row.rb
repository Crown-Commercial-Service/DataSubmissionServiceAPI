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
          invoice_date,
          value_for('InvoiceNumber'),
          value_for('SupplierReferenceNumber', default: nil),
          value_for('CustomerReferenceNumber', default: nil),
          value_for('LotNumber', default: nil),
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
          invoice.management_charge,
          *values_for_additional
        ]
      end
      # rubocop:enable Metrics/AbcSize

      private

      def invoice_date
        formatted_date value_for('InvoiceDate')
      end
    end
  end
end

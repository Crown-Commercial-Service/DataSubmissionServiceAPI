module Export
  class Invoices
    class Row < SubmissionEntriesStageRow
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
          unit_price,
          value_for('UnitQuantity'),
          invoice_value,
          value_for('Expenses', default: nil),
          vat_charged,
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

      def unit_price
        formatted_decimal value_for('UnitPrice')
      end

      def invoice_value
        formatted_decimal value_for('InvoiceValue')
      end

      def vat_charged
        formatted_decimal value_for('VATCharged')
      end
    end
  end
end

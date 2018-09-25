module Export
  class Invoices
    class Row < Export::CsvRow
      alias_method :invoice, :model

      def row_values
        [
          invoice.submission_id,
          customer_urn,
          customer_name,
          customer_postcode,
          invoice_date,
          invoice_number
        ]
      end

      def customer_urn
        value_for('CustomerURN')
      end

      def customer_name
        value_for('CustomerName')
      end

      def customer_postcode
        value_for('CustomerPostCode')
      end

      def invoice_date
        value_for('InvoiceDate')
      end

      def invoice_number
        value_for('InvoiceNumber')
      end

      private

      def value_for(destination_field, default: NOT_IN_DATA)
        source_field = Export::Template.source_field_for(
          destination_field,
          invoice._framework_short_name
        )
        invoice.data.fetch(source_field, default)
      end
    end
  end
end

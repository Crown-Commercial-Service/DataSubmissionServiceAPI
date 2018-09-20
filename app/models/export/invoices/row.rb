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
        MISSING
      end

      def customer_name
        MISSING
      end

      def customer_postcode
        MISSING
      end

      def invoice_date
        MISSING
      end

      def invoice_number
        MISSING
      end
    end
  end
end

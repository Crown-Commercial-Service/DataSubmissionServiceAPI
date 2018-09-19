module Export
  class Invoices
    class Row
      MISSING = '#MISSING'.freeze

      attr_reader :invoice

      def initialize(invoice)
        @invoice = invoice
      end

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

      def to_csv_line
        CSV.generate_line(row_values)
      end
    end
  end
end

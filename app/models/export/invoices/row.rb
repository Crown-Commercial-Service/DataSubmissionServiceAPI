module Export
  class Invoices
    class Row
      attr_reader :invoice

      def initialize(invoice)
        @invoice = invoice
      end

      def row_values
        [
          invoice.submission_id,
        ]
      end

      def to_csv_line
        CSV.generate_line(row_values)
      end
    end
  end
end

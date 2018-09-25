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
        invoice.data['Customer URN'] || NOT_IN_DATA
      end

      def customer_name
        invoice.data['Customer Organisation Name'] || NOT_IN_DATA
      end

      def customer_postcode
        invoice.data['Customer Post Code'] || NOT_IN_DATA
      end

      def invoice_date
        invoice.data['Customer Invoice Date'] || NOT_IN_DATA
      end

      def invoice_number
        invoice.data['Customer Invoice Number'] || NOT_IN_DATA
      end
    end
  end
end

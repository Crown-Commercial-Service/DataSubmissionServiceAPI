module Export
  class Invoices
    class Row < SubmissionEntryRow
      alias_method :invoice, :model

      # rubocop:disable Metrics/AbcSize
      def row_values
        [
          invoice.submission_id,
          customer_urn,
          customer_name,
          customer_postcode,
          invoice_date,
          invoice_number,
          supplier_reference_number,
          customer_reference_number,
          lot_number,
          product_description,
          product_group,
          product_class,
          product_subclass,
          product_code,
          unit_type,
          unit_price,
          unit_quantity,
          invoice_value,
          expenses,
          vat_charged,
          promotion_code,
          additional1,
          additional2,
          additional3,
          additional4,
          additional5,
          additional6,
          additional7,
          additional8,
        ]
      end
      # rubocop:enable Metrics/AbcSize

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

      def supplier_reference_number
        value_for('SupplierReferenceNumber')
      end

      def customer_reference_number
        nil
      end

      def lot_number
        value_for('LotNumber')
      end

      def product_description
        value_for('ProductDescription', default: nil)
      end

      def product_group
        value_for('ProductGroup', default: nil)
      end

      def product_class
        value_for('ProductClass', default: nil)
      end

      def product_subclass
        value_for('ProductSubClass', default: nil)
      end

      def product_code
        value_for('ProductCode', default: nil)
      end

      def unit_type
        value_for('UnitType')
      end

      def unit_price
        value_for('UnitPrice')
      end

      def unit_quantity
        value_for('UnitQuantity')
      end

      def invoice_value
        value_for('InvoiceValue')
      end

      def expenses
        value_for('Expenses', default: nil)
      end

      def vat_charged
        value_for('VATCharged')
      end

      def promotion_code
        value_for('PromotionCode', default: nil)
      end
    end
  end
end

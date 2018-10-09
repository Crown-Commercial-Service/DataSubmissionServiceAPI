module Export
  class Submissions
    class Row < Export::CsvRow
      alias_method :submission, :model

      def row_values
        [
          submission.task_id,
          submission.id,
          status,
          submission_type,
          submission_file_type,
          contract_entry_count,
          order_value,
          invoice_entry_count,
          invoice_value,
          management_charge_value,
          management_charge_rate,
          created_date,
          created_by,
          supplier_approved_date,
          supplier_approved_by,
          finance_export_date,
          po_number
        ]
      end

      def status
        {
          'completed'         => 'supplier_accepted',
          'validation_failed' => 'validation_failed'
        }.fetch(submission.aasm_state)
      end

      def submission_type
        (invoice_entry_count + contract_entry_count).zero? ? 'no_business' : 'file'
      end

      def submission_file_type
        File.extname(submission._first_filename).downcase[1..-1] if submission._first_filename
      end

      def management_charge_value
        format('%0.2f', submission.management_charge / 100.0) if submission.management_charge
      end

      def management_charge_rate
        (Framework::TMP_FIXED_CHARGE_RATE / 100).to_s
      end

      def created_date
        submission.created_at.utc.iso8601
      end

      def po_number
        submission.purchase_order_number
      end

      # Fields that are nil for MVP
      def created_by; end

      def supplier_approved_date; end

      def supplier_approved_by; end

      def finance_export_date; end

      def invoice_value
        format_money(submission._total_invoice_value)
      end

      def order_value
        format_money(submission._total_order_value)
      end

      private

      def contract_entry_count
        submission._order_entry_count
      end

      def invoice_entry_count
        submission._invoice_entry_count
      end

      def format_money(amount)
        return '0.00' if amount.nil?
        format '%.2f', amount.truncate(2)
      end
    end
  end
end

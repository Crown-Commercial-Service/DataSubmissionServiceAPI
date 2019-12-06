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
          'replaced'          => 'replaced',
          'validation_failed' => 'validation_failed'
        }.fetch(submission.aasm_state)
      end

      def submission_type
        submission._first_filename.blank? ? 'no_business' : 'file'
      end

      def submission_file_type
        File.extname(submission._first_filename).downcase[1..-1] if submission._first_filename
      end

      def management_charge_value
        format_money(submission.management_charge_total)
      end

      def management_charge_rate
        '#REMOVED'
      end

      def created_date
        submission.created_at.utc.iso8601
      end

      def po_number
        submission.purchase_order_number
      end

      def created_by
        submission.created_by.try(:name)
      end

      def supplier_approved_by
        submission.submitted_by.try(:name)
      end

      def supplier_approved_date
        submission.submitted_at.utc.iso8601 if submission.submitted_at.present?
      end

      # Fields that are nil for MVP
      def finance_export_date; end

      def order_value
        format_money(submission._total_order_value)
      end

      private

      def contract_entry_count
        submission._order_entry_count
      end

      def format_money(amount)
        return '0.00' if amount.nil?

        format '%.2f', amount.truncate(2)
      end
    end
  end
end

module Export
  class Submissions
    class Row
      ERROR   = '#ERROR'.freeze
      MISSING = '#MISSING'.freeze # fields that are needed for MVP that we don't have yet

      attr_reader :submission, :errors

      def initialize(submission)
        @submission = submission
        @errors = Hash.new { |hash, column_name| hash[column_name] = [] }
      end

      def row_values
        [
          submission.task_id,
          submission.id,
          status,
          submission_type,
          submission_file_type,
          order_entry_count,
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
      rescue KeyError
        errors['Status'] << "#{submission.aasm_state} is not mapped to Submission column Status"
        ERROR
      end

      def submission_type
        (invoice_entry_count + order_entry_count).zero? ? 'no_business' : 'file'
      end

      def submission_file_type
        File.extname(submission._first_filename).downcase[1..-1]
      end

      def management_charge_value
        format('%0.2f', submission.management_charge / 100.0) if submission.management_charge
      end

      def management_charge_rate
        format('%0.3f', Framework::TMP_FIXED_CHARGE_RATE / 100)
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

      def to_csv_line
        CSV.generate_line(row_values)
      end

      def invoice_value
        MISSING
      end

      def order_value
        MISSING
      end

      private

      def order_entry_count
        submission._order_entry_count
      end

      def invoice_entry_count
        submission._invoice_entry_count
      end
    end
  end
end

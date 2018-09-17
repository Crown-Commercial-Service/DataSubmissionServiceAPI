module Export
  class Submissions
    class Row
      ERROR   = '#ERROR'.freeze
      MISSING = '#MISSING'.freeze

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
          management_charge_value
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
        submission.management_charge
      end

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

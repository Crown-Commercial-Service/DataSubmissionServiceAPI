module Export
  class Submissions
    class Row
      ERROR = '#ERROR'

      attr_reader :submission, :errors

      def initialize(submission)
        @submission = submission
        @errors = Hash.new { |hash, column_name| hash[column_name] = [] }
      end

      def row_values
        [
          submission.task_id,
          submission.id,
          status
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

      def to_csv_line
        CSV.generate_line(row_values)
      end
    end
  end
end

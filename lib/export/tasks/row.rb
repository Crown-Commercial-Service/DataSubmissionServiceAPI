module Export
  class Tasks
    class Row
      # Always 1 for now. May be used to indicate different task types in future.
      FIXED_TASK_TYPE = 1
      EMPTY_FOR_NOW = nil

      attr_reader :task

      def initialize(task)
        @task = task
      end

      def year_and_month
        "#{task.period_year}#{format('%02d', task.period_month)}"
      end

      def row_values
        [
          task.id,
          year_and_month,
          task.supplier_id,
          task.framework_id,
          task.status,
          FIXED_TASK_TYPE,
          EMPTY_FOR_NOW,
          EMPTY_FOR_NOW
        ]
      end

      def to_csv_line
        CSV.generate_line(row_values)
      end
    end
  end
end

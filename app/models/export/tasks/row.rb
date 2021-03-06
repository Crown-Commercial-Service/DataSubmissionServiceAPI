module Export
  class Tasks
    class Row < Export::CsvRow
      # Always 1 for now. May be used to indicate different task types in future.
      FIXED_TASK_TYPE = 1
      EMPTY_FOR_NOW = nil

      alias_method :task, :model

      def year_and_month
        "#{task.period_year}-#{format('%02d', task.period_month)}"
      end

      def status
        case task.status
        when 'correcting'
          'completed'
        when 'in_progress'
          task.active_submission.aasm_state.to_s
        else
          task.status
        end
      end

      def row_values
        [
          task.id,
          year_and_month,
          task.supplier.salesforce_id,
          task.framework.short_name,
          status,
          FIXED_TASK_TYPE,
          EMPTY_FOR_NOW,
          EMPTY_FOR_NOW
        ]
      end
    end
  end
end

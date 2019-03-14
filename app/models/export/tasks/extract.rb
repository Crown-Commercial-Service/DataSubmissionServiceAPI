module Export
  class Tasks
    module Extract
      def self.all_relevant(date_range = nil)
        tasks = Task.includes(:framework, :supplier)
        tasks = tasks.where(updated_at: date_range) if date_range.present?
        tasks
      end
    end
  end
end

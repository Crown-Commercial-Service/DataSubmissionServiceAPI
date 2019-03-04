module Export
  class Tasks
    module Extract
      def self.all_relevant
        Task.includes(:framework, :supplier)
      end
    end
  end
end

require 'csv'

module Export
  class Tasks
    HEADER = %w[
      TaskID
      Month
      SupplierID
      FrameworkID
      Status
      TaskType
      StartedDate
      CompletedDate
    ].freeze

    attr_reader :tasks, :output

    def initialize(tasks, output)
      @tasks = tasks
      @output = output
    end

    def run
      output.puts(CSV.generate_line(HEADER))
      tasks.each do |task|
        output.puts(Row.new(task).to_csv_line)
      end
    end
  end
end

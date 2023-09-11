require 'csv'

module Export
  class Tasks < ToIo
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
  end
end

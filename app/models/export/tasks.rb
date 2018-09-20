require 'csv'

module Export
  class Tasks < ToIO
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

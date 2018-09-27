require 'csv'

module Export
  class Contracts < ToIO
    HEADER = %w[
      SubmissionID
      CustomerURN
    ].freeze
  end
end

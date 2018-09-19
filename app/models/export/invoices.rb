require 'csv'

module Export
  class Invoices
    HEADER = %w[
      SubmissionID
      CustomerURN
      CustomerName
      CustomerPostcode
    ].freeze

    attr_reader :invoices, :output

    def initialize(invoices, output)
      @invoices = invoices
      @output = output
    end

    def run
      output.puts(CSV.generate_line(HEADER))
      invoices.each do |invoice|
        output.puts(Row.new(invoice).to_csv_line)
      end
    end
  end
end

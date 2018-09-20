module Export
  class ToIO
    attr_reader :relation, :output

    def initialize(relation, output)
      @relation = relation
      @output = output
    end

    def run
      output.puts(CSV.generate_line(self.class::HEADER))
      relation.each do |model|
        output.puts(self.class::Row.new(model).to_csv_line)
      end
    end
  end
end

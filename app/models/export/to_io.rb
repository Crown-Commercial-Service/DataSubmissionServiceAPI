module Export
  class ToIO
    attr_reader :relation, :output

    def initialize(relation, output)
      @relation = relation
      @output = output
    end

    def run
      output.puts(CSV.generate_line(self.class::HEADER))
      cache = {}
      relation.find_each do |model|
        output_row(model, cache)
      end
    end

    def output_row(model, cache)
      output.puts(self.class::Row.new(model, cache).to_csv_line)
    end
  end
end

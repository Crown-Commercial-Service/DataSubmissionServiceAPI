module Export
  class CsvRow
    NOT_IN_DATA = '#NOTINDATA'.freeze # fields that we looked for in the JSONB data and could not find

    attr_reader :model, :cache

    def initialize(model, cache)
      @model = model
      @cache = cache
    end

    def to_csv_line
      CSV.generate_line(row_values)
    end
  end
end

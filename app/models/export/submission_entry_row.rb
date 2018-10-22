module Export
  ##
  # Used for SubmissionEntries with entry_types of
  # order and invoice, such that we can fetch mapped values
  # from their hashed +data+ field.
  #
  # These rows also define 8 additional ++AdditionalN++ fields.
  class SubmissionEntryRow < CsvRow
    US_DATE_FORMAT = %r(^(\d{1,2})\/(\d{1,2})\/(\d{2})$)
    UK_DATE_FORMAT = %r(^(\d{1,2})\/(\d{1,2})\/(\d{4})$)

    def value_for(destination_field, default: NOT_IN_DATA)
      source_field = source_field_for(destination_field)
      model.data.fetch(source_field, default)
    end

    def values_for_additional
      (1..8).map do |n|
        value_for("Additional#{n}", default: nil)
      end
    end

    def formatted_date(date_string)
      if date_string&.match UK_DATE_FORMAT
        Date.strptime(date_string, '%d/%m/%Y').iso8601
      elsif date_string&.match US_DATE_FORMAT
        Date.strptime(date_string, '%m/%d/%y').iso8601
      else
        date_string
      end
    rescue ArgumentError
      date_string
    end

    private

    def source_field_for(destination_field)
      framework_definition = Framework::Definition[model._framework_short_name]
      sheet_definition = framework_definition.for_entry_type(model.entry_type)
      sheet_definition.export_mappings[destination_field]
    end
  end
end

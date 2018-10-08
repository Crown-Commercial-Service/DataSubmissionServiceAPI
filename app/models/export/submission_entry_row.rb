module Export
  ##
  # Used for SubmissionEntries with entry_types of
  # order and invoice, such that we can fetch mapped values
  # from their hashed +data+ field.
  #
  # These rows also define 8 additional ++AdditionalN++ fields.
  class SubmissionEntryRow < CsvRow
    def value_for(destination_field, default: NOT_IN_DATA)
      source_field = source_field_for(destination_field)
      model.data.fetch(source_field, default)
    end

    def values_for_additional
      (1..8).map do |n|
        value_for("Additional#{n}", default: nil)
      end
    end

    private

    def source_field_for(destination_field)
      sheet_definition = sheet_definition(model._framework_short_name, model.entry_type)
      sheet_definition.export_mappings[destination_field]
    end

    def sheet_definition(framework_short_name, entry_type)
      "Framework::Definition::#{framework_short_name}::#{entry_type.titleize}".constantize
    rescue NameError
      raise Framework::Definition::MissingError, %(Please run rails g framework:definition "#{framework_short_name}")
    end
  end
end

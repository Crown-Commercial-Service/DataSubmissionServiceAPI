module Export
  ##
  # Used for SubmissionEntries with entry_types of
  # order and invoice, such that we can fetch mapped values
  # from their hashed +data+ field.
  #
  # These rows also define 8 additional ++AdditionalN++ fields.
  class SubmissionEntryRow < CsvRow
    include Export::Template

    def value_for(destination_field, default: NOT_IN_DATA)
      source_field = source_field_for(
        destination_field,
        model._framework_short_name
      )
      model.data.fetch(source_field, default)
    end

    def values_for_additional
      (1..8).map do |n|
        value_for("Additional#{n}", default: nil)
      end
    end
  end
end

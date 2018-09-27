module Export
  ##
  # Used for SubmissionEntries with entry_types of
  # order and invoice, such that we can fetch mapped values
  # from their hashed +data+ field.
  #
  # These rows also define 8 additional ++AdditionalN++ fields.
  class SubmissionEntryRow < CsvRow
    (1..8).each do |n|
      define_method "additional#{n}" do
        value_for("Additional#{n}", default: nil)
      end
    end

    protected

    def value_for(destination_field, default: NOT_IN_DATA)
      source_field = Export::Template.source_field_for(
        destination_field,
        model._framework_short_name
      )
      model.data.fetch(source_field, default)
    end
  end
end

require './lib/string_utils'

module Export
  ##
  # Used for SubmissionEntries with entry_types of
  # order and invoice, such that we can fetch mapped values
  # from their hashed +data+ field.
  #
  # These rows also define 8 additional ++AdditionalN++ fields.
  class SubmissionEntryRow < CsvRow
    include ActionView::Helpers::TextHelper
    NUMBER_OF_ADDITIONAL_FIELDS = 24

    include StringUtils

    def value_for(destination_field, default: NOT_IN_DATA)
      source_field = source_field_for(destination_field)
      value = model.data.fetch(source_field, default)
      truncate(value, length: 255) if value.is_a? String
    end

    def values_for_additional
      (1..NUMBER_OF_ADDITIONAL_FIELDS).map do |n|
        value_for("Additional#{n}", default: nil)
      end
    end

    def formatted_date(date_string)
      parse_date_string(date_string)&.iso8601 || date_string
    end

    def formatted_decimal(value)
      return '#NOTINDATA' if value == '#NOTINDATA'

      value = value.gsub(/([^0-9.\-]+)/, '').to_f if value.is_a?(String)
      value
    end

    def self.additional_field_names
      (1..NUMBER_OF_ADDITIONAL_FIELDS).map { |n| "Additional#{n}" }
    end

    private

    def framework_definition_for(framework_short_name)
      cache[framework_short_name] ||= Framework::Definition[framework_short_name]
    end

    def source_field_for(destination_field)
      framework_definition = framework_definition_for(model._framework_short_name)
      entry_data_definition = framework_definition.for_entry_type(model.entry_type)
      entry_data_definition.export_mappings[destination_field]
    end
  end
end

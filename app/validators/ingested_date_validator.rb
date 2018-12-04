require './lib/string_utils'

class IngestedDateValidator < ActiveModel::EachValidator
  include StringUtils

  def validate_each(record, attribute, value)
    record.errors.add(attribute, error_message(record, attribute)) unless parse_date_string(value)
  end

  private

  def error_message(record, attribute)
    attribute_optional?(record, attribute) ? :invalid_optional_ingested_date : :invalid_ingested_date
  end

  def attribute_optional?(record, attribute)
    validator = record.class.validators_on(attribute).find { |v| v.is_a?(IngestedDateValidator) }
    validator.options[:allow_nil]
  end
end

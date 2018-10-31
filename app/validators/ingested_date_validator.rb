require './lib/string_utils'

class IngestedDateValidator < ActiveModel::EachValidator
  include StringUtils

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_ingested_date) unless parse_date_string(value)
  end
end

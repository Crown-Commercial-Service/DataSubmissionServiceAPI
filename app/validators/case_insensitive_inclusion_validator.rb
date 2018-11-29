class CaseInsensitiveInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid_values = Array(options[:in]).map(&:downcase)

    return if value.nil?
    return if valid_values.include?(value.downcase)

    record.errors.add(attribute, :inclusion, value: value, message: options[:message])
  end
end

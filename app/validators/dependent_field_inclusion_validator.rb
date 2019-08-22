class DependentFieldInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parent_field_values = get_parent_field_values(record)
    parent_field_value_lookup = parent_field_values.map { |v| v&.downcase }

    valid_values = get_valid_values(parent_field_value_lookup)
    return if valid_values.include?(value&.downcase)

    record.errors.add(
      attribute,
      :invalid_dependent_field,
      value: value,
      attr: attribute,
      parent_field_name: parent_field_names.join(', '),
      parent_field_value: parent_field_values.join(', ')
    )
  end

  private

  def parent_field_names
    options[:parents]
  end

  def get_parent_field_values(record)
    parent_field_names.map { |name| record.attributes[name] }
  end

  def get_valid_values(lookup_key)
    mapping = options[:in].deep_transform_keys { |key| key.map(&:downcase) }
    matching_key = mapping.keys.find { |key| key == lookup_key }
    matching_values = matching_key ? mapping[matching_key] : []

    matching_values.map(&:downcase)
  end
end

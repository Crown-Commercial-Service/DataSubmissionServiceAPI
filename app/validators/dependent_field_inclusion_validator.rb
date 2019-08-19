class DependentFieldInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parent_field_names = options[:parents]
    parent_field_values = parent_field_names.map { |name| record.attributes[name] }

    parent_field_value_lookup = parent_field_values.map { |v| v&.downcase }

    mapping = options[:in].deep_transform_keys { |key| key.map(&:downcase) }

    valid_values = mapping[parent_field_value_lookup]&.map(&:downcase) || []
    return if value&.downcase&.in?(valid_values)

    record.errors.add(
      attribute,
      :invalid_dependent_field,
      value: value,
      attr: attribute,
      parent_field_name: parent_field_names.join(', '),
      parent_field_value: parent_field_values.join(', ')
    )
  end
end

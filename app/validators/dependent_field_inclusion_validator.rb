class DependentFieldInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parent_field_name = options[:parent]
    parent_field_value = record.attributes[parent_field_name]

    parent_field_value_lookup = parent_field_value&.downcase

    mapping = options[:in].deep_transform_keys { |key| key.to_s.downcase }

    valid_values = mapping[parent_field_value_lookup]&.map(&:downcase) || []
    return if value&.downcase&.in?(valid_values)

    record.errors.add(
      attribute,
      :invalid_dependent_field,
      value: value,
      attr: attribute,
      parent_field_name: parent_field_name,
      parent_field_value: parent_field_value
    )
  end
end

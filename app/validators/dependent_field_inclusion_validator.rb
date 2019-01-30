class DependentFieldInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parent_field_name = options[:parent]
    parent_field_value = record.attributes[parent_field_name]
    parent_field_value_lookup = parent_field_value.to_s.downcase
    mapping = options[:in]

    valid_values = mapping.dig(parent_field_name, parent_field_value_lookup).map(&:downcase)
    return if value.downcase.in?(valid_values)

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

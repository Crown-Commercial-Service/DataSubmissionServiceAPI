class UrnValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if Customer.exists?(urn: value)

    record.errors.add(attribute, :invalid_urn)
  end
end

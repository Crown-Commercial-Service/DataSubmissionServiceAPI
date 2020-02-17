class UrnValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if numeric?(value) && Customer.exists?(urn: value)

    record.errors.add(attribute, :invalid_urn)
  end

  private

  def numeric?(value)
    # This is cheaper than 'Integer(value) rescue false'
    value.to_i.to_s == value
  end
end

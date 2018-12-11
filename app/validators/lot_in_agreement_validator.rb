class LotInAgreementValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if record.valid_lot_numbers.include?(value)

    record.errors.add(attribute, :invalid_lot_number)
  end
end

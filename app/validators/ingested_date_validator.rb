class IngestedDateValidator < ActiveModel::EachValidator
  US_DATE_FORMAT = %r(^(\d{1,2})\/(\d{1,2})\/(\d{2})$)
  UK_DATE_FORMAT = %r(^(\d{1,2})\/(\d{1,2})\/(\d{4})$)

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_ingested_date) unless valid_date_string?(value)
  end

  private

  def valid_date_string?(value)
    case value
    when UK_DATE_FORMAT then Date.strptime(value, '%d/%m/%Y')
    when US_DATE_FORMAT then Date.strptime(value, '%m/%d/%y')
    else false
    end
  rescue ArgumentError
    false
  end
end

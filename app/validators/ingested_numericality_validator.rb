class IngestedNumericalityValidator < ActiveModel::Validations::NumericalityValidator
  def validate_each(record, attribute, value)
    super(record, attribute, value)
  end
end

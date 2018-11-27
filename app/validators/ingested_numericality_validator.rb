class IngestedNumericalityValidator < ActiveModel::Validations::NumericalityValidator
  TREAT_AS_ZERO = ['n/a', 'na', 'n.a', 'not applicable', '-'].freeze

  def validate_each(record, attribute, value)
    return true if TREAT_AS_ZERO.include?(value.to_s.strip.downcase)

    super(record, attribute, value)
  end
end

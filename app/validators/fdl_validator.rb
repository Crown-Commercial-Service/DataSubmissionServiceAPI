class FdlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    generator = Framework::Definition::Generator.new(value, Logger.new('/dev/null'))
    record.errors.add(attribute, :fdl, value: value, message: generator.error) if generator.error?
  end
end

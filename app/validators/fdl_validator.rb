class FdlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Framework::Definition::Language.parse(value, Logger.new('/dev/null'))
  rescue Parslet::ParseFailed => e
    record.errors.add(attribute, :fdl, value: value, message: e.parse_failure_cause.ascii_tree)
  end
end

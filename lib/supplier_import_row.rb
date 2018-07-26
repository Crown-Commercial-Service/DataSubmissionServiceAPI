class SupplierImportRow
  REQUIRED_KEYS = %i[frameworkreference suppliername].freeze

  def initialize(row)
    @row = row

    check_for_required_keys!
  end

  def import!
    supplier = Supplier.find_or_create_by!(name: @row[:suppliername])
    framework = Framework.find_by!(short_name: @row[:frameworkreference])

    supplier.agreements.find_or_create_by!(framework: framework)
  end

  private

  def check_for_required_keys!
    raise MissingKey unless (REQUIRED_KEYS - @row.keys).empty?
  end

  class MissingKey < StandardError; end
end

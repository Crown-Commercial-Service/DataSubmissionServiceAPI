class SupplierImportRow
  def initialize(row)
    @row = row
  end

  def import!
    supplier = Supplier.find_or_create_by!(name: @row[:suppliername])
    framework = Framework.find_by!(short_name: @row[:frameworkreference])

    supplier.agreements.find_or_create_by!(framework: framework)
  end
end

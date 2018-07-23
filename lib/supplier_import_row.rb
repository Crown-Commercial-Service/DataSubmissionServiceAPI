class SupplierImportRow
  def initialize(row)
    @row = row
  end

  def import!
    supplier = Supplier.create!(name: @row[:suppliername])
    framework = Framework.find_by!(short_name: @row[:frameworkreference])

    supplier.agreements.create!(framework: framework)
  end
end

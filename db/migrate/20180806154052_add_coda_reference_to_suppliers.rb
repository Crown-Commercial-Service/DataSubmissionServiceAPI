class AddCodaReferenceToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :coda_reference, :string, limit: 7
  end
end

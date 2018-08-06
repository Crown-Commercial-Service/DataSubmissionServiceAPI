class AddCodaReferenceToFrameworks < ActiveRecord::Migration[5.2]
  def change
    add_column :frameworks, :coda_reference, :integer
  end
end

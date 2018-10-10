class AddSalesforceIdToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :salesforce_id, :string
    add_index :suppliers, :salesforce_id, unique: true
  end
end

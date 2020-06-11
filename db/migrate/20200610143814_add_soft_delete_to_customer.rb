class AddSoftDeleteToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :deleted, :boolean, default: false
  end
end

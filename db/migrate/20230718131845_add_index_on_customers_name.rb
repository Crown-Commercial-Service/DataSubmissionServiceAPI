class AddIndexOnCustomersName < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :customers,
              :name,
              order: { name: :asc },
              algorithm: :concurrently
  end
end

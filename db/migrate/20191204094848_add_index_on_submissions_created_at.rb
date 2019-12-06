class AddIndexOnSubmissionsCreatedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :submissions,
              :created_at,
              order: { created_at: :desc },
              algorithm: :concurrently
  end
end

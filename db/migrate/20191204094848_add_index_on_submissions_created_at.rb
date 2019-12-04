class AddIndexOnSubmissionsCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :submissions,
              :created_at,
              order: { created_at: :desc }
  end
end

class AddMissingIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :submissions,        :updated_at, using: :brin, algorithm: :concurrently
    add_index :submission_entries, :updated_at, using: :brin, algorithm: :concurrently
    add_index :submission_entries_stages, :updated_at, using: :brin, algorithm: :concurrently
    add_index :tasks,              :updated_at, using: :brin, algorithm: :concurrently
  end
end

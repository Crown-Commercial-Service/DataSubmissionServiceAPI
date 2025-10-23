class AddIndexToSubmissionsCleanupProcessed < ActiveRecord::Migration[8.0]
  def change
    add_index :submissions, :cleanup_processed
  end
end

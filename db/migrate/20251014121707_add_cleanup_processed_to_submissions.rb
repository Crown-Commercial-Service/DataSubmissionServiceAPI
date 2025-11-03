class AddCleanupProcessedToSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :cleanup_processed, :boolean, default: false, null: false
  end
end

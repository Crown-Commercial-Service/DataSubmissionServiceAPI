class AddRunKeyToNotificationBatches < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_batches, :run_key, :string

    add_index :notification_batches, :run_key, unique: true
  end
end

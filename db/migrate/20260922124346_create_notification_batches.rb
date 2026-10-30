class CreateNotificationBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_batches, id: :uuid do |t|
      t.string :notification_type, null: false
      t.integer :period_month
      t.integer :period_year
      t.string :template_id, null: false
      t.string :status, null: false, default: 'running'
      t.datetime :started_at, null: false
      t.datetime :completed_at

      t.timestamps
    end
  end
end

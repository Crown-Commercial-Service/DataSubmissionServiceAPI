class CreateNotificationDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_deliveries, id: :uuid do |t|
      t.references :notification_batch, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false
      t.string :supplier_name, null: false
      t.string :notify_id
      t.string :reference, null: false
      t.string :status, null: false, default: 'pending'
      t.string :error_code
      t.text :error_message
      t.datetime :sent_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :notification_deliveries, :notify_id, unique: true
    add_index :notification_deliveries, :reference, unique: true
  end
end

class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications, id: :uuid do |t|

      t.text :notification_message
      t.boolean :published, default: false
      t.datetime :published_at
      t.datetime :unpublished_at
      t.string :user      
    end

    add_index :notifications, :published
  end
end

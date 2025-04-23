class AddSummaryToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :summary, :text, null: false, default: 'Important'
  end
end

class RemoveDefaultFromSummaryInNotifications < ActiveRecord::Migration[7.1]
  def change
    change_column_default :notifications, :summary, nil
  end
end

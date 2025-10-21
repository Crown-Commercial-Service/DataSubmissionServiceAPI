class RemovePublishedFromFrameworks < ActiveRecord::Migration[8.0]
  def change
    remove_column :frameworks, :published
  end
end

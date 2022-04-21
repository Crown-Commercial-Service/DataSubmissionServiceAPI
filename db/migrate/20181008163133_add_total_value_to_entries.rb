class AddTotalValueToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :total_value, :decimal
    add_column :submission_entries_stages, :total_value, :decimal
  end
end

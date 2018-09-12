class AddEntryTypeToSubmissionEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :entry_type, :string
    add_index :submission_entries, :entry_type
  end
end

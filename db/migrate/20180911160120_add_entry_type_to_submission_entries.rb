class AddEntryTypeToSubmissionEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :entry_type, :string
    add_index :submission_entries, :entry_type

    add_column :submission_entries_stages, :entry_type, :string
    add_index :submission_entries_stages, :entry_type
  end
end

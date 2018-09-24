class AddIndexToSubmissionEntriesSourceRow < ActiveRecord::Migration[5.2]
  def change
    add_index :submission_entries, :source, using: :gin
  end
end

class AddAasmStateToSubmissionEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :aasm_state, :string
    add_index :submission_entries, :aasm_state
  end
end

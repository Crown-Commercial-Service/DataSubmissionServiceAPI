class AddIndexToSubmissionsOnTaskIdAndAasmState < ActiveRecord::Migration[8.0]
  def change
    add_index :submissions, [:task_id, :aasm_state], name: 'index_submissions_on_task_id_and_aasm_state'
  end
end

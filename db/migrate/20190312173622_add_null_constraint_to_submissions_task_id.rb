class AddNullConstraintToSubmissionsTaskId < ActiveRecord::Migration[5.2]
  def change
    change_column :submissions, :task_id, :uuid, null: false
  end
end

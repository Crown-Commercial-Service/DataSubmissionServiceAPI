class AddTaskToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_reference :submissions, :task, foreign_key: true, type: :uuid
  end
end

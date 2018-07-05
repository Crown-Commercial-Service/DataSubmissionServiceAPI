class AddRowsToSubmissionFile < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_files, :rows, :integer
  end
end

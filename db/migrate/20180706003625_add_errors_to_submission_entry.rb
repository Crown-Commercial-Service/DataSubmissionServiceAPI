class AddErrorsToSubmissionEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :validation_errors, :jsonb
  end
end

class AddErrorsToSubmissionEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :validation_errors, :jsonb
    add_column :submission_entries_stages, :validation_errors, :jsonb
  end
end

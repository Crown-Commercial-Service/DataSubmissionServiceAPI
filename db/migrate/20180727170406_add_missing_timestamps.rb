class AddMissingTimestamps < ActiveRecord::Migration[5.2]
  def change
    # from: https://stackoverflow.com/questions/46520907/add-timestamps-to-existing-table-in-db-rails-5?rq=1
    # add new column but allow null values
    add_timestamps :submissions, null: true
    add_timestamps :submission_files, null: true

    # backfill existing record with created_at and updated_at
    # values making clear that the records are faked
    long_ago = DateTime.new(2000, 1, 1)
    Submission.update_all(created_at: long_ago, updated_at: long_ago)
    SubmissionFile.update_all(created_at: long_ago, updated_at: long_ago)

    # change not null constraints
    change_column_null :submissions, :created_at, false
    change_column_null :submissions, :updated_at, false
    change_column_null :submission_files, :created_at, false
    change_column_null :submission_files, :updated_at, false
  end
end

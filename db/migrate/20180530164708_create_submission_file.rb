class CreateSubmissionFile < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_files, id: :uuid do |t|
      t.references :submission, foreign_key: true, null: false, type: :uuid
    end
  end
end

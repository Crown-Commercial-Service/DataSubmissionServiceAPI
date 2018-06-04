class CreateSubmissionEntry < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_entries, id: :uuid do |t|
      t.references :submission, foreign_key: true, null: false, type: :uuid
      t.references :submission_file, foreign_key: true, null: true, type: :uuid

      t.jsonb :source
      t.jsonb :data

      t.timestamps
    end
  end
end

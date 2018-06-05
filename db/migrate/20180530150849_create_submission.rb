class CreateSubmission < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions, id: :uuid do |t|
      t.references :framework, foreign_key: true, null: false, type: :uuid
      t.references :supplier, foreign_key: true, null: false, type: :uuid
    end
  end
end

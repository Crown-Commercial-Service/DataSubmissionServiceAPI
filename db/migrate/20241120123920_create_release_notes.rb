class CreateReleaseNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :release_notes, id: :uuid do |t|
      t.text :header, null: false
      t.text :body, null: false
      t.boolean :published, default: false

      t.timestamps
    end
  end
end

class CreateApiKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.string :key, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :api_keys, :key, unique: true
  end
end

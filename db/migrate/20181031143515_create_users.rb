class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :auth_id
      t.string :name
      t.string :email
      t.index :auth_id, unique: true

      t.timestamps
    end
  end
end

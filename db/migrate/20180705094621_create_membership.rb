class CreateMembership < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.references :supplier, foreign_key: true, null: false, type: :uuid
      t.timestamps
    end

    add_index :memberships, :user_id
  end
end

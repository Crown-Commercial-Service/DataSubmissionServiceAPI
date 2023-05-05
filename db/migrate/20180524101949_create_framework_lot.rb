class CreateFrameworkLot < ActiveRecord::Migration[5.2]
  def change
    create_table :framework_lots, id: :uuid do |t|
      t.references :framework, foreign_key: true, null: false, type: :uuid
      # t.uuid :framework_id, foreign_key: true, null: false
      t.string :number, null: false
      t.string :description
    end

    add_index :framework_lots, [:framework_id, :number], unique: true
  end
end

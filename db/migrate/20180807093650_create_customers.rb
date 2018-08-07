class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :name, null: false
      t.string :postcode
      t.integer :urn, null: false
      t.integer :sector, null: false

      t.timestamps
    end

    add_index :customers, :urn, unique: true
    add_index :customers, :postcode
    add_index :customers, :sector
  end
end

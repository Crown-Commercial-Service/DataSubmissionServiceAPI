class CreateSupplier < ActiveRecord::Migration[5.2]
  def change
    create_table :suppliers, id: :uuid do |t|
      t.string :name, null: false
    end
  end
end

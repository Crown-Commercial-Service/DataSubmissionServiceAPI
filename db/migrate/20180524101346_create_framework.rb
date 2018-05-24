class CreateFramework < ActiveRecord::Migration[5.2]
  def change
    create_table :frameworks, id: :uuid do |t|
      t.string :name
      t.string :short_name, null: false
    end

    add_index :frameworks, :short_name, unique: true
  end
end

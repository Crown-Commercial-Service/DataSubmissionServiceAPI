class CreateUrnList < ActiveRecord::Migration[5.2]
  def change
    create_table :urn_lists, id: :uuid do |t|
      t.timestamps
      t.string :aasm_state
    end

    add_index :urn_lists, :aasm_state
  end
end

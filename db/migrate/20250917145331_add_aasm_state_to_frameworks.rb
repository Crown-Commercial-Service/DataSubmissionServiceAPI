class AddAasmStateToFrameworks < ActiveRecord::Migration[8.0]
  def up
    add_column :frameworks, :aasm_state, :string, null: false, default: 'new'
    add_index :frameworks, :aasm_state

    Framework.reset_column_information
    Framework.where(published: true).update_all(aasm_state: 'published')
    Framework.where(published: false).update_all(aasm_state: 'new')
  end

  def down
    remove_index :frameworks, :aasm_state
    remove_column :frameworks, :aasm_state
  end
end

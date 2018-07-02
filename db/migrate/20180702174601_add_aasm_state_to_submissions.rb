class AddAasmStateToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :aasm_state, :string
    add_index :submissions, :aasm_state
  end
end

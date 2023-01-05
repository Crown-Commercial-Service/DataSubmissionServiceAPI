class CreateBulkUserUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_user_uploads, id: :uuid do |t|
      t.timestamps
      t.string :aasm_state
    end
    
    add_index :bulk_user_uploads, :aasm_state
  end
end

class AddPublishedToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :published, :boolean, default: true
  end
end

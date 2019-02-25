class AddActiveToAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :agreements, :active, :boolean, default: true
    add_index :agreements, :active
  end
end

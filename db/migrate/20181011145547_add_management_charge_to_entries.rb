class AddManagementChargeToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :management_charge, :decimal, precision: 18, scale: 4
  end
end

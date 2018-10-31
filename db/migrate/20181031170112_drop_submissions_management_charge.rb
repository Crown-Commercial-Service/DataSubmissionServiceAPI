class DropSubmissionsManagementCharge < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :management_charge
  end
end

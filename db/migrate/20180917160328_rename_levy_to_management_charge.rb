class RenameLevyToManagementCharge < ActiveRecord::Migration[5.2]
  def change
    rename_column :submissions, :levy, :management_charge
  end
end

class AddManagementChargeTotalToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :management_charge_total, :decimal, precision: 18, scale: 4
  end
end

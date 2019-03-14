class CreateDataWarehouseExport < ActiveRecord::Migration[5.2]
  def change
    create_table :data_warehouse_exports do |t|
      t.datetime :range_from, null: false
      t.datetime :range_to, null: false, index: true
    end
  end
end

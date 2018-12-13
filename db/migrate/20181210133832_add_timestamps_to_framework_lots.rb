class AddTimestampsToFrameworkLots < ActiveRecord::Migration[5.2]
  def change
    change_table :framework_lots do |t|
      t.timestamps
    end
  end
end

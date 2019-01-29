class AddRevenueCategoryWidToFrameworks < ActiveRecord::Migration[5.2]
  def change
    add_column :frameworks, :revenue_category_wid, :string
  end
end

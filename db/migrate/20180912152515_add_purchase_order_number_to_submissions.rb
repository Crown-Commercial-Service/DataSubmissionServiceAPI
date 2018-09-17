class AddPurchaseOrderNumberToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :purchase_order_number, :string
  end
end

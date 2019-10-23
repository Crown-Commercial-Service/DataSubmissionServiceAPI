class AddSummaryInvoiceTotalToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :invoice_total, :decimal, precision: 18, scale: 4
  end
end

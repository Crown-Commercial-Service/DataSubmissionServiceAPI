class AddReversalToSubmissionInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_invoices, :reversal, :boolean, default: false, null: false
  end
end

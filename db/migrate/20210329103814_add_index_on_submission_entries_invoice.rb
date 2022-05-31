class AddIndexOnSubmissionEntriesInvoice < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :submission_entries, :entry_type, where: "entry_type = 'invoice'", name: 'index_submission_entries_on_invoice_entry_type', algorithm: :concurrently
    add_index :submission_entries_stages, :entry_type, where: "entry_type = 'invoice'", name: 'index_submission_entries_stage_on_invoice_entry_type', algorithm: :concurrently
  end
end

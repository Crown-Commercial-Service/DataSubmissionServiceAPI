class CreateSubmissionInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_invoices, id: :uuid do |t|
      t.references :submission, foreign_key: true, type: :uuid, null: false
      t.string :workday_reference

      t.timestamps
    end
  end
end

class AddCustomerUrnToSubmissionEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_entries, :customer_urn, :integer
    add_foreign_key :submission_entries, :customers, column: :customer_urn, primary_key: :urn
  end
end

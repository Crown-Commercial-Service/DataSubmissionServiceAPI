class AddSubmittedByAndSubmittedAtToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_reference :submissions, :submitted_by, foreign_key: { to_table: :users }, type: :uuid
    add_column :submissions, :submitted_at, :datetime
  end
end

class AddCreatedByToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_reference :submissions, :created_by, foreign_key: { to_table: :users }, type: :uuid
  end
end

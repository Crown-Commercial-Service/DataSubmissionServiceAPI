class AddLevyToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :levy, :integer, null: true
  end
end

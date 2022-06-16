class CreateCustomerEffortScores < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_effort_scores, id: :uuid do |t|
      t.integer :rating
      t.string :comments

      t.datetime :created_at
    end
  end
end

class AddUserToCustomerEffortScores < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_effort_scores, :user, foreign_key: true, type: :uuid
  end
end

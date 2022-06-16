class AddNullConstraintToRating < ActiveRecord::Migration[5.2]
  def change
    change_column_null :customer_effort_scores, :rating, false
  end
end

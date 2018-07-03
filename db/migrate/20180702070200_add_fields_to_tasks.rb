class AddFieldsToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :description, :string
    add_column :tasks, :due_on, :date

    add_column :tasks, :period_month, :integer
    add_column :tasks, :period_year, :integer

    add_reference :tasks, :supplier, foreign_key: true, type: :uuid
    add_reference :tasks, :framework, foreign_key: true, type: :uuid
  end
end

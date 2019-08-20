class MakeFrameworkDefinitionSourceNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :frameworks, :definition_source, :text, null: false
  end
end

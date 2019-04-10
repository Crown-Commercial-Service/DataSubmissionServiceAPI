class AddFrameworkDefinitionSource < ActiveRecord::Migration[5.2]
  def change
    add_column :frameworks, :definition_source, :text
  end
end

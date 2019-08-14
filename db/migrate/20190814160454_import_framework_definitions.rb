class ImportFrameworkDefinitions < ActiveRecord::Migration[5.2]
  def up
    fdl_root = Rails.root.join('app', 'models', 'framework', 'definition')

    Framework.where(definition_source: nil).each do |framework|
      name   = framework.short_name.tr('./', '_')
      path   = fdl_root.join("#{name}.fdl")
      source = path.exist? ? path.read : nil

      framework.update!(definition_source: source)
    end
  end
end

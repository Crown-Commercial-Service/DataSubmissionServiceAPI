class AddFdlPublishingColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :frameworks, :definition_source, :text
    add_column :frameworks, :published, :boolean, default: false

    # While published defaults to false for all new frameworks,
    # we want all existing frameworks to appear published
    ActiveRecord::Base.connection.execute(
      <<~PostgreSQL
        UPDATE frameworks SET published = true
      PostgreSQL
    )
  end
end

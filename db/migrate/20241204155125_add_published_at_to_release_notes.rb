class AddPublishedAtToReleaseNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :release_notes, :published_at, :datetime
  end
end

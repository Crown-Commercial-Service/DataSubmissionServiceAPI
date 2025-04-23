class ReleaseNote < ApplicationRecord
  validates :header, :body, presence: true

  scope :published, -> { where(published: true) }

  def publish!
    self.published =  true
    self.published_at = Time.zone.now
    save!
  end
end

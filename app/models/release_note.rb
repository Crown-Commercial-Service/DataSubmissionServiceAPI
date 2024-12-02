class ReleaseNote < ApplicationRecord
  validates :header, :body, presence: true

  scope :published, -> { where(published: true) }

  def publish!
    update(published: true)
  end
end

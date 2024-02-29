class Notification < ApplicationRecord
  validates :notification_message, presence: true

  before_save :ensure_single_published_notification

  scope :published, -> { where(published: true) }

  def unpublish!
    self.published = false
    self.unpublished_at = Time.zone.now 
    save!
  end

  private

  def ensure_single_published_notification
    if published_changed? && published? 
      Notification.where.not(id: id).where(published: true).find_each do |notification|
        notification.unpublish!
      end
    end
  end
end

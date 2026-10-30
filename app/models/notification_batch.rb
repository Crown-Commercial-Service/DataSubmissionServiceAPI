class NotificationBatch < ApplicationRecord
  RETENTION_PERIOD = 30.days

  has_many :notification_deliveries, dependent: :destroy

  validates :notification_type, :template_id, :status, :started_at, presence: true

  scope :expired, -> { where('created_at < ?', RETENTION_PERIOD.ago) }

  def self.purge_expired!
    expired.find_each(&:destroy!)
  end
end

class NotificationDelivery < ApplicationRecord
  belongs_to :notification_batch

  validates :email, :supplier_name, :reference, :status, presence: true
  validates :reference, uniqueness: true
  validates :notify_id, uniqueness: true, allow_nil: true
end

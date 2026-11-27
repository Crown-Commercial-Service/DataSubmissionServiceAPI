class PurgeExpiredNotificationBatchesJob < ApplicationJob
  queue_as :default

  def perform
    NotificationBatch.purge_expired!
  end
end

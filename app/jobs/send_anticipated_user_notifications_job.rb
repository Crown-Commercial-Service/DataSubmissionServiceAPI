class SendAnticipatedUserNotificationsJob < ApplicationJob
  queue_as :default

  TEMPLATE_ID = ENV.fetch('GOV_NOTIFY_ANTICIPATED_USER_TEMPLATE_ID')

  def perform(month: Time.current.month, year: Time.current.year)
    batch = NotificationBatch.create!(
      notification_type: 'due',
      period_month: month,
      period_year: year,
      template_id: TEMPLATE_ID,
      status: 'running',
      started_at: Time.current
    )

    Task::AnticipatedUserNotifications.new(month: month, year: year).each do |notification|
      delivery = batch.notification_deliveries.create!(
        email: notification[:email],
        supplier_name: notification[:supplier_name],
        reference: SecureRandom.uuid,
        status: 'pending'
      )

      SendTaskNotificationJob.perform_later(delivery.id, notification[:personalisation])
    end

    batch.update!(status: 'submitted', completed_at: Time.current)
  rescue StandardError => e
    batch&.update!(status: 'failed', completed_at: Time.current)
    raise
  end
end

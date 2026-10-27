class SendUserNotificationsJob < ApplicationJob
  queue_as :default

  NOTIFICATION_TYPES = {
    'due' => {
      template_env: 'GOV_NOTIFY_ANTICIPATED_USER_TEMPLATE_ID',
      selector_type: :anticipated
    },
    'duetoday' => {
      template_env: 'GOV_NOTIFY_DUE_TODAY_USER_TEMPLATE_ID',
      selector_type: :incomplete
    },
    'overdue' => {
      template_env: 'GOV_NOTIFY_OVERDUE_USER_TEMPLATE_ID',
      selector_type: :incomplete
    },
    'late' => {
      template_env: 'GOV_NOTIFY_LATE_USER_TEMPLATE_ID',
      selector_type: :incomplete
    },
    'unfinished' => {
      template_env: 'GOV_NOTIFY_UNFINISHED_USER_TEMPLATE_ID',
      selector_type: :unfinished
    }
  }.freeze

  def perform(notification_type:, month: nil, year: nil, run_key: nil)
    config = NOTIFICATION_TYPES.fetch(notification_type.to_s)

    if config[:selector_type] != :unfinished && (month.nil? || year.nil?)
      raise ArgumentError, "Month and year must be provided for notification type: #{notification_type}."
    end

    if run_key.present? && NotificationBatch.exists?(run_key: run_key)
      return
    end

    begin 
      batch = NotificationBatch.create!(
        notification_type: notification_type,
        period_month: month,
        period_year: year,
        template_id: ENV.fetch(config[:template_env]),
        run_key: run_key,
        status: 'running',
        started_at: Time.current
      )
    rescue ActiveRecord::RecordNotUnique
      raise if run_key.blank?
      batch = NotificationBatch.exists?(run_key: run_key)

      return 
    end

    notifications_for(config, month: month, year: year).each do |notification|
      delivery = batch.notification_deliveries.create!(
        email: notification[:email],
        supplier_name: notification[:supplier_name],
        reference: SecureRandom.uuid,
        status: 'pending'
      )

      SendTaskNotificationJob.perform_later(delivery.id, notification[:personalisation])
    end

    batch.update!(status: 'submitted', completed_at: Time.current)
  rescue StandardError
    batch&.update!(status: 'failed', completed_at: Time.current)
    raise
  end

  private

  def notifications_for(config, month:, year:)
    case config[:selector_type]
    when :anticipated, :incomplete
      Task::UserNotificationRecipients.new(month: month, year: year, type: config[:selector_type])
    when :unfinished
      Task::UnfinishedUserNotifications.new
    else
      raise ArgumentError, "Unknown selector type: #{config[:selector_type]}."
    end
  end
end
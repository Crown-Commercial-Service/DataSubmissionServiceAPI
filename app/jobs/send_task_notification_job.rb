class SendTaskNotificationJob < ApplicationJob
  queue_as :default

  def perform(delivery_id, personalisation)
    delivery = NotificationDelivery.find(delivery_id)

    response = Notify.new.send_email(
      template_id: delivery.notification_batch.template_id,
      email: delivery.email,
      vars: personalisation,
      reference: delivery.reference
    )

    delivery.update!(
      notify_id: response&.id,
      status: 'created',
      sent_at: Time.current
    )
  rescue Notifications::Client::RequestError => e
    delivery&.update!(
      status: 'request-failed',
      error_code: error_code(e),
      error_message: e.message,
      completed_at: Time.current
    )
  end

  private

  def error_code(error)
    error.respond_to?(:code) ? error.code : 'unknown'
  end
end

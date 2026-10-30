class GovNotifyCallbacksController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_notify

  def delivery
    delivery =
      NotificationDelivery.find_by(notify_id: params[:id]) ||
      NotificationDelivery.find_by(reference: params[:reference])

    return head :not_found unless delivery

    delivery.update(
      notify_id: params[:id],
      status: params[:status],
      sent_at: params[:sent_at] || delivery.sent_at,
      completed_at: params[:completed_at]
    )

    head :no_content
  end

  private

  def authenticate_notify
    authenticate_or_request_with_http_token do |token|
      ActiveSupport::SecurityUtils.secure_compare(
        token,
        ENV.fetch('GOV_NOTIFY_CALLBACK_TOKEN')
      )
    end
  end
end

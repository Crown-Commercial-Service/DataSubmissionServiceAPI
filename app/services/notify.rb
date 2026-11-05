require 'notifications/client'

class Notify
  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(template_id:, email:, vars: {}, reference: nil)
    @client.send_email(
      email_address: email,
      template_id: template_id,
      personalisation: vars,
      reference: reference
    )
  rescue Notifications::Client::RequestError => e
    Rails.logger.error "GOV.UK Notify Error: #{e.message}"
    raise
  end
end

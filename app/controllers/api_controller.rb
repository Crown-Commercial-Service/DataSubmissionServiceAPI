class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  before_action :authenticate
  before_action :reject_without_user!

  def authenticate
    return if ENV['API_PASSWORD'].blank?

    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == 'dxw' && password == ENV['API_PASSWORD']
    end
  end

  def current_user
    if token
      @current_user ||= User.find_by(auth_id: current_auth_id)
    end
  end

  private

  def reject_without_user!
    raise ActionController::BadRequest, 'Invalid X-Auth-Id' if current_user.nil?
  end

  def token
    request.env["HTTP_X_AUTH_ID"]
  end

  def current_auth_id
    Auth.decode(token)
  end
end

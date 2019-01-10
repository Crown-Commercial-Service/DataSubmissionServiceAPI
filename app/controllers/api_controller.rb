class APIController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  before_action :authenticate

  def authenticate
    return if ENV['API_PASSWORD'].blank?

    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == 'dxw' && password == ENV['API_PASSWORD']
    end
  end
end

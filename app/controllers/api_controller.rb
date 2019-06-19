class APIController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :reject_without_user!

  def current_user
    @current_user ||= User.find_by(auth_id: current_auth_id)
  end

  def current_auth_id
    @current_auth_id ||= begin
                           authenticate_or_request_with_http_token do |token, _options|
                             payload = JWT.decode(token, public_key, true, algorithm: 'RS256')
                             payload[0]['sub'] # auth_id
                           end
                         end
  end

  private

  def reject_without_user!
    raise ActionController::BadRequest, 'Invalid authorisation header' if current_user.nil?
  end

  def public_key
    @public_key ||= begin
                      pubkey = ENV['AUTH0_JWT_PUBLIC_KEY']
                      OpenSSL::PKey.read(pubkey)
                    end
  end
end

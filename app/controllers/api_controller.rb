class APIController < ActionController::API
  before_action :reject_without_user!

  def current_user
    @current_user ||= User.find_by(auth_id: current_auth_id)
  end

  def current_auth_id
    request.headers['X-Auth-Id']
  end

  private

  def reject_without_user!
    raise ActionController::BadRequest, 'Invalid authorisation header' if current_user.nil?
  end
end

class AdminController < ActionController::Base
  layout 'admin'
  before_action :ensure_user_signed_in

  helper_method :current_user

  private

  def current_user
    session[:admin_account]
  end

  def ensure_user_signed_in
    return if current_user.present? && ENV['ADMIN_EMAILS'].split(',').include?(current_user['email'])

    redirect_to '/auth/google_oauth2'
  end
end

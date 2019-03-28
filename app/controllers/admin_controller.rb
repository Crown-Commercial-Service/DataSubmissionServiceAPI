class AdminController < ActionController::Base
  layout 'admin'
  before_action :ensure_user_signed_in

  helper_method :current_user

  add_flash_types :success, :failure, :notice, :warning

  private

  def current_user
    session[:admin_account]
  end

  def ensure_user_signed_in
    return if current_user.present? && ENV['ADMIN_EMAILS'].split(',').include?(current_user['email'])

    redirect_to admin_sign_in_path
  end
end

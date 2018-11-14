class Admin::SessionsController < AdminController
  skip_before_action :ensure_user_signed_in

  def create
    if authorized_email?
      session[:admin_account] = user_hash
      redirect_to admin_root_path
    else
      render plain: 'Not authorized'
    end
  end

  def destroy
    session[:admin_account] = nil
    redirect_to admin_root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def user_hash
    {
      'name' => auth_hash.info.name,
      'email' => auth_hash.info.email,
    }
  end

  def authorized_email?
    ENV['ADMIN_EMAILS'].split(',').include?(user_hash['email'])
  end
end

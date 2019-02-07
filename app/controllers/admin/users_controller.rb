class Admin::UsersController < AdminController
  def index
    @users = User.search(params[:search]).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @memberships = @user.memberships.includes(:supplier)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    User.transaction do
      if @user.save
        @user.create_with_auth0
        redirect_to admin_user_path(@user)
      else
        render action: :new
      end
    rescue Auth0::Exception
      flash[:alert] = 'There was an error adding the user to Auth0. Please try again.'
      render action: :new
      raise ActiveRecord::Rollback
    end
  end

  def confirm_delete
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.deactivate
    flash[:alert] = 'User has been deleted'
    redirect_to admin_users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

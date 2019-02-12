class Admin::UsersController < AdminController
  before_action :find_user, except: %i[index create new]

  def index
    @users = User.search(params[:search]).page(params[:page])
  end

  def show
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

  def edit
    @user.create_with_auth0
  rescue Auth0::Exception
    flash[:alert] = 'There was an error adding the user to Auth0. Please try again.'
  ensure
    redirect_to admin_user_path(@user)
  end

  def confirm_delete; end

  def confirm_reactivate; end

  def destroy
    @user.deactivate
    flash[:alert] = 'User has been deactivated'
    redirect_to admin_users_path
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

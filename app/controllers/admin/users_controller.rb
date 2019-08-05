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
    if @user.valid?
      result = CreateUser.new(user: @user).call
      flash[:alert] = I18n.t('error_adding_user_to_auth0') if result.failure?

      return redirect_to admin_user_path(@user) if @user.persisted?
    end
    render action: :new
  end

  def edit
    @user = User.find(params[:id])
    result = ReactivateUser.new(user: @user).call
    flash[:alert] = I18n.t('error_adding_user_to_auth0') if result.failure?

    redirect_to admin_user_path(@user)
  end

  def confirm_delete
    @user = User.find(params[:id])
  end

  def confirm_reactivate
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.deactivate
    flash[:alert] = 'User has been deactivated'
    redirect_to admin_users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

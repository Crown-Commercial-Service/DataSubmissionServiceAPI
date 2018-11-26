class Admin::UsersController < AdminController
  def index
    @users = User.search(params[:search]).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.create_with_auth0
      redirect_to admin_user_path(@user)
    else
      render action: :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

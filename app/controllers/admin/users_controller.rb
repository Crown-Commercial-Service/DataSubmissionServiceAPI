class Admin::UsersController < AdminController
  def index
    @users = User.search(params[:search]).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end
end

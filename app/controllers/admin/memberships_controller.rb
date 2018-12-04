class Admin::MembershipsController < AdminController
  before_action :find_user
  def new
    @suppliers = Supplier.excluding(@user.suppliers).order(:name).search(params[:search]).page(params[:page])
  end

  def create
    @user.memberships.create!(membership_params)
    redirect_to admin_user_path(@user)
  end

  def show
    @membership = @user.memberships.find(params[:id])
  end

  def destroy
    @membership = @user.memberships.find(params[:id])
    @membership.destroy
    redirect_to admin_user_path(@user)
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def membership_params
    params.require(:membership).permit(:supplier_id)
  end
end

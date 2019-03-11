class Admin::SuppliersController < AdminController
  def index
    @suppliers = Supplier.search(params[:search]).page(params[:page])
  end

  def show
    @supplier = Supplier.find(params[:id])
    @tasks = @supplier.tasks.includes(:framework, :active_submission).order(due_on: :desc)
  end
end

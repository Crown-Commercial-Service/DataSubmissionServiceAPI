class Admin::SuppliersController < AdminController
  def index
    @suppliers = Supplier.search(params[:search]).page(params[:page])
  end

  def show
    @supplier = Supplier.find(params[:id])
    @tasks = @supplier.tasks.includes(:framework,
                                      active_submission: :files).order(due_on: :desc).page(params[:task_page]).per(12)
    @users = @supplier.users.page(params[:user_page]).per(12)
    @agreements = @supplier.agreements.includes(:framework).page(params[:framework_page]).per(12)
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update(supplier_params)
      flash[:success] = 'Supplier updated successfully.'
      redirect_to admin_supplier_path(@supplier)
    else
      render action: :edit
    end
  end

  private

  def supplier_params
    params.require(:supplier).permit(:name, :salesforce_id)
  end
end

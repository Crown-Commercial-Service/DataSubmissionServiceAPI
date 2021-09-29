class Admin::SuppliersController < AdminController
  before_action :find_supplier, only: %i[show edit update show_tasks show_users show_frameworks]
  before_action :load_frameworks, only: %i[show show_tasks]

  def index
    @suppliers = Supplier.search(params[:search]).page(params[:page])
  end

  def show_tasks
    @tasks = @supplier.tasks.includes(:framework, active_submission: :files)
                      .order(due_on: :desc, id: :desc).page(params[:task_page]).per(12)
    @tasks = @tasks.where(framework_id: params[:framework_id]) if params[:framework_id]
  end

  def show_users
    @users = @supplier.users.page(params[:user_page]).per(12)

    filter_user_status params[:status] if params[:status]
  end

  def show_frameworks
    @agreements = @supplier.agreements.joins(:framework).merge(Framework.order(short_name: :asc)).page(params[:framework_page]).per(12)

    filter_framework_status params[:status] if params[:status]
  end

  def show
    show_tasks
    show_users
    show_frameworks

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit; end

  def update
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

  def find_supplier
    @supplier = Supplier.find(params[:id])
  end

  def load_frameworks
    @tasks = @supplier.tasks
    @frameworks = @tasks.collect(&:framework).uniq.sort_by(&:short_name)
  end

  def filter_user_status(status_param)
    return if status_param.size == 2

    @users = @users.active if status_param.include? 'active'
    @users = @users.inactive if status_param.include? 'inactive'
  end

  def filter_framework_status(status_param)
    return if status_param.size == 2

    @agreements = @agreements.active if status_param.include? 'active'
    @agreements = @agreements.inactive if status_param.include? 'inactive'
  end
end

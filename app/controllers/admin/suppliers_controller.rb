class Admin::SuppliersController < AdminController
  before_action :find_supplier, only: %i[show edit update show_tasks show_users]
  before_action :load_frameworks, only: %i[show show_tasks show_users]

  def index
    @suppliers = Supplier.search(params[:search]).page(params[:page])
  end

  def show_tasks
    @tasks = @supplier.tasks.includes(:framework,
                                      active_submission: :files).order(due_on: :desc).page(params[:task_page]).per(12)
    @tasks = @tasks.where(framework_id: params[:framework_id]) if params[:framework_id]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show_users
    @users = @supplier.users.page(params[:user_page]).per(12)

    filter_status params[:status] if params[:status]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    show_tasks
    show_users
    @agreements = @supplier.agreements.includes(:framework).page(params[:framework_page]).per(12)

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
    @tasks = @supplier.tasks.includes(:framework, active_submission: :files)
    @frameworks = @tasks.collect(&:framework).uniq.sort_by { |framework| framework.short_name }
  end

  def filter_status(status_param)
    return if status_param.size == 2

    @users = @users.active if status_param.include? 'active'
    @users = @users.inactive if status_param.include? 'inactive'
  end
end

class Admin::TasksController < AdminController
  before_action :find_supplier

  def new
    @task = @supplier.tasks.build
  end

  def create
    @task = @supplier.tasks.build(task_params)
    if @task.save
      flash[:success] = 'Task added successfully.'
      redirect_to admin_supplier_path(@supplier)
    else
      render action: :new
    end
  end

  private

  def find_supplier
    @supplier = Supplier.find(params[:supplier_id])
  end

  def task_params
    params.require(:task).permit(:period_year, :period_month, :framework_id)
  end
end

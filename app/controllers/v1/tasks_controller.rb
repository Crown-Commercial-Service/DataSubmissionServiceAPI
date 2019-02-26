class V1::TasksController < APIController
  deserializable_resource :task, only: %i[create update]

  def index
    tasks = current_user.tasks
    tasks = tasks.where(status: params.dig(:filter, :status)) if params.dig(:filter, :status)

    render jsonapi: tasks, include: params.dig(:include), fields: sparse_field_params
  end

  def show
    task = current_user.tasks.find(params[:id])

    render jsonapi: task, include: params.dig(:include)
  end

  def update
    task = Task.find(params[:id])
    task.update(task_params)

    if task.save
      head :no_content
    else
      render jsonapi_errors: task.errors, status: :bad_request
    end
  end

  def no_business
    task = current_user.tasks.find(params[:id])

    if task.completed? && !replacement_return?
      render jsonapi: task.submissions.first
      return
    end

    if task.completed? && replacement_return?
      task.latest_submission.replace_with_no_business!
      task.reload
    end

    task.file_no_business!(current_user)
    submission = task.latest_submission

    render jsonapi: submission, status: :created
  end

  def complete
    task = current_user.tasks.find(params[:id])
    task.status = 'completed'

    if task.save
      render jsonapi: task
    else
      render jsonapi_errors: task.errors, status: :bad_request
    end
  end

  private

  def task_params
    params.require(:task).permit(:supplier_id, :framework_id, :status, :due_on,
                                 :period_month, :period_year, :description)
  end

  def sparse_field_params
    fields_param = params.permit(fields: {}).to_h[:fields] || {}
    Hash[fields_param.map { |k, v| [k.to_sym, v.split(',').map!(&:to_sym)] }]
  end

  def replacement_return?
    params.dig('_jsonapi', 'replacement').to_s.downcase == 'true'
  end
end

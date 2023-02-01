class V1::TasksController < APIController
  deserializable_resource :task, only: %i[create update]

  def index
    tasks = current_user.tasks
    tasks = tasks.includes(:supplier).includes(requested_associations)
    tasks = tasks.where(status: params.dig(:filter, :status)) if params.dig(:filter, :status)
    tasks = tasks.where(framework_id: params.dig(:filter, :framework_id)) if params.dig(:filter, :framework_id)
    tasks = tasks.order('due_on ASC', 'frameworks.name ASC') if requested_associations.include?(:framework)

    render jsonapi: tasks, include: params[:include], fields: sparse_field_params
  end

  def show
    task = current_user.tasks.find(params[:id])

    render jsonapi: task, include: params[:include], expose: { include_file: params[:include_file] }
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

    task.cancel_correction if task.correcting?

    if task.completed? && !correcting_submission?
      render jsonapi: task.active_submission
      return
    end

    if task.completed? && correcting_submission?
      task.active_submission.replace_with_no_business!(current_user)
      task.reload
    end

    task.file_no_business!(current_user)
    submission = task.active_submission

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

  def cancel_correction
    task = current_user.tasks.find(params[:id])
    task.cancel_correction!

    render jsonapi: task
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

  def correcting_submission?
    params.dig('_jsonapi', 'correction').to_s.downcase == 'true'
  end

  def requested_associations
    params.fetch(:include, '').split(',').map(&:to_sym)
  end
end

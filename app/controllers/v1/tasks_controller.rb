class V1::TasksController < ApplicationController
  deserializable_resource :task, only: [:create]

  def create
    task = Task.new(task_params)

    if task.save
      render jsonapi: task, status: :created
    else
      render jsonapi_errors: task.errors, status: :bad_request
    end
  end

  def index
    tasks = if params.dig(:filter, :status)
              Task.where(status: params.dig(:filter, :status))
            else
              Task.all
            end

    render jsonapi: tasks
  end

  def complete
    @task = Task.find(params[:id])
    @task.update(status: 'completed')
  end

  private

  def task_params
    params.require(:task).permit(:status)
  end
end

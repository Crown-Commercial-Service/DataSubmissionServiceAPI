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
    tasks = Task.where(nil)
    tasks = tasks.where(status: params.dig(:filter, :status)) if params.dig(:filter, :status)
    tasks = tasks.where(supplier_id: params.dig(:filter, :supplier_id)) if params.dig(:filter, :supplier_id)

    render jsonapi: tasks
  end

  def show
    task = Task.find(params[:id])

    render jsonapi: task
  end

  def complete
    task = Task.find(params[:id])
    task.status = 'complete'

    if task.save
      render jsonapi: task
    else
      render jsonapi_errors: task.errors, status: :bad_request
    end
  end

  private

  def task_params
    params.require(:task).permit(:status, :supplier_id)
  end
end

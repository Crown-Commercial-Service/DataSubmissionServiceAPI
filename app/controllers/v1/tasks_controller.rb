class V1::TasksController < ApplicationController
  def create
    @task = Task.new(task_params)
    if @task.save
      render json: @task, status: :created
    else
      render json: @task.errors, status: :bad_request
    end
  end

  def index
    @tasks = if params[:status].present?
               Task.where(status: params[:status])
             else
               Task.all
             end
  end

  def complete
    @task = Task.find(params[:id])
    @task.update(status: 'completed')
  end

  private

  def task_params
    params.permit(:status)
  end
end

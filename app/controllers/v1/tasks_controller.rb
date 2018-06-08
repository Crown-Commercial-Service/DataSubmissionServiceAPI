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
    if params[:status].present?
      @tasks = Task.where(status: params[:status])
    else
      @tasks = Task.all
    end
  end

  private

  def task_params
    params.permit(:status)
  end
end

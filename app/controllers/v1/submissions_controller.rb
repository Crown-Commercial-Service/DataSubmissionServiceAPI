class V1::SubmissionsController < ApplicationController
  deserializable_resource :submission, only: %i[create update]

  def show
    submission = Submission.find(params[:id])

    render jsonapi: submission, include: params.dig(:include)
  end

  def create
    task = Task.find(params.dig(:submission, :task_id))

    submission = task.submissions.new(
      framework: task.framework,
      supplier: task.supplier,
      purchase_order_number: params.dig(:submission, :purchase_order_number)
    )

    if submission.save
      render jsonapi: submission, status: :created
    else
      render jsonapi_errors: submission.errors, status: :bad_request
    end
  end

  def update
    submission = Submission.find(params[:id])
    submission.levy = update_submission_params[:levy] * 100
    submission.ready_for_review!

    if submission.save
      head :no_content
    else
      render jsonapi_errors: submission.errors, status: :bad_request
    end
  end

  def complete
    submission = Submission.find(params[:id])
    complete_submission!(submission)

    if submission.errors.empty?
      head :no_content
    else
      render jsonapi_errors: submission.errors, status: :bad_request
    end
  end

  private

  def complete_submission!(submission)
    SubmissionCompletion.new(submission).perform!
  end

  def update_submission_params
    params.require(:submission).permit(:levy)
  end
end

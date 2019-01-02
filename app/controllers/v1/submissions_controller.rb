class V1::SubmissionsController < APIController
  deserializable_resource :submission, only: %i[create update]

  def show
    submission = current_user.submissions.find(params[:id])

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

  def complete
    submission = Submission.find(params[:id])
    complete_submission!(submission)

    if submission.errors.empty?
      head :no_content
    else
      render jsonapi_errors: submission.errors, status: :bad_request
    end
  end

  def validate
    submission = Submission.find(params[:id])
    SubmissionValidationJob.perform_later(submission)

    head :no_content
  end

  private

  def complete_submission!(submission)
    SubmissionCompletion.new(submission).perform!
  end
end

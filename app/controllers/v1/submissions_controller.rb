class V1::SubmissionsController < APIController
  deserializable_resource :submission, only: %i[create update]

  skip_before_action :reject_without_user!, only: %i[validate]

  def show
    submission = current_user.submissions.find(params[:id])

    render jsonapi: submission, include: params.dig(:include)
  end

  def create
    task = Task.find(params.dig(:submission, :task_id))

    if !correcting_submission? && task.active_submission&.completed?
      render jsonapi_errors: [{ title: 'Task already has completed submission.' }], status: :conflict
      return
    end

    submission = task.submissions.new(
      framework: task.framework,
      supplier: task.supplier,
      created_by: current_user,
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

    head :no_content
  end

  def validate
    return head :no_content if ENV['NEW_INGEST'] == 'true'

    submission = Submission.find(params[:id])
    SubmissionValidationJob.perform_later(submission)

    head :no_content
  end

  private

  def complete_submission!(submission)
    SubmissionCompletion.new(submission, current_user).perform!
  end

  def correcting_submission?
    params.dig(:submission, :correction).to_s.downcase == 'true'
  end
end

class V1::SubmissionFilesController < APIController
  deserializable_resource :submission_file, only: %i[update]
  def create
    submission = Submission.find(params[:submission_id])
    submission_file = submission.files.new

    if submission_file.save
      render jsonapi: submission_file, status: :created
    else
      render jsonapi: submission_file.errors, status: :bad_request
    end
  end

  def update
    submission_file = SubmissionFile.find(params[:id])
    submission_file.rows = submission_file_params[:rows] if submission_file_params[:rows]
    if submission_file.save
      head :no_content
    else
      render jsonapi: submission_file.errors, status: :bad_request
    end
  end

  def show
    submission_file = SubmissionFile.find(params[:id])

    render jsonapi: submission_file, status: :ok
  end

  private

  def submission_file_params
    params.require(:submission_file).permit(:rows)
  end
end

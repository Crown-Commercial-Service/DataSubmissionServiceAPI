class V1::SubmissionFilesController < ApplicationController
  def create
    submission = Submission.find(submission_file_params[:submission_id])
    submission_file = submission.files.new

    if submission_file.save
      render jsonapi: submission_file, status: :created
    else
      render jsonapi: submission_file.errors, status: :bad_request
    end
  end

  def update
    SubmissionFile.find(params[:id])

    # TODO: Store the updated file

    head :no_content
  end

  private

  def submission_file_params
    params.permit(:submission_id)
  end
end

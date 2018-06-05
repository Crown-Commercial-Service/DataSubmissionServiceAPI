class V1::SubmissionFilesController < ApplicationController
  def create
    submission = Submission.find(submission_file_params[:submission_id])

    @submission_file = submission.files.new

    if @submission_file.save
      render json: @submission_file, status: :created
    else
      render json: @submission_file.errors, status: :bad_request
    end
  end

  private

  def submission_file_params
    params.permit(:submission_id)
  end
end

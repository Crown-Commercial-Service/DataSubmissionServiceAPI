class V1::SubmissionEntriesController < ApplicationController
  def create
    @entry = initialize_submission_entry

    @entry.source = submission_entry_params[:source]
    @entry.data = submission_entry_params[:data]

    if @entry.save
      render json: @entry, status: :created
    else
      render json: @entry.errors, status: :bad_request
    end
  end

  private

  def initialize_submission_entry
    if submission_entry_params[:file_id].present?
      file = SubmissionFile.find(submission_entry_params[:file_id])
      file.entries.new(submission: file.submission)
    else
      submission = Submission.find(submission_entry_params[:submission_id])
      submission.entries.new
    end
  end

  def submission_entry_params
    params.permit(:file_id, :submission_id, source: {}, data: {})
  end
end

class V1::SubmissionEntriesController < ApplicationController
  deserializable_resource :submission_entry, only: [:create]

  def create
    entry = initialize_submission_entry

    entry.source = submission_entry_params[:source]
    entry.data = submission_entry_params[:data]

    if entry.save
      render jsonapi: entry, status: :created
    else
      render jsonapi_errors: entry.errors, status: :bad_request
    end
  end

  def show
    submission_file = SubmissionFile.find(params[:file_id])
    entry = submission_file.entries.find(params[:id])

    render jsonapi: entry, status: :ok
  end

  private

  def initialize_submission_entry
    if params[:file_id].present?
      file = SubmissionFile.find(params[:file_id])
      file.entries.new(submission: file.submission)
    else
      submission = Submission.find(params[:submission_id])
      submission.entries.new
    end
  end

  def submission_entry_params
    params.require(:submission_entry).permit(source: {}, data: {})
  end
end

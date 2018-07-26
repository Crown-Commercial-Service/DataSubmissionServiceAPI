class V1::SubmissionEntriesController < ApplicationController
  deserializable_resource :submission_entry, only: %i[create update]

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

  def update
    submission_file = SubmissionFile.find(params[:file_id])
    entry = submission_file.entries.find(params[:id])
    entry.aasm.current_state = submission_entry_params[:status]
    entry.validation_errors = submission_entry_params[:validation_errors]

    if entry.save
      submission_status_update!(submission_file.submission)
      head :no_content
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

  def submission_status_update!(submission)
    SubmissionStatusUpdate.new(submission).perform!
  end

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
    params
      .require(:submission_entry)
      .permit(:status, :type, source: {}, data: {}, validation_errors: [:message, location: {}])
  end
end

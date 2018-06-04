class V1::SubmissionEntriesController < ApplicationController
  def create
    file = SubmissionFile.find(submission_entry_params[:file_id])

    @entry = file.entries.new
    @entry.submission = file.submission

    @entry.source = submission_entry_params[:source]
    @entry.data = submission_entry_params[:data]

    if @entry.save
      render json: @entry, status: :created
    else
      render json: @entry.errors, status: :bad_request
    end
  end

  private

  def submission_entry_params
    params.permit(:file_id, :submission_id, source: {}, data: {})
  end
end

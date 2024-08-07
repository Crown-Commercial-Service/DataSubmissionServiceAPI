# frozen_string_literal: true

class V1::SubmissionFileBlobsController < ApiController
  deserializable_resource :file_blob

  def create
    submission_file = SubmissionFile.find(params[:file_id])
    submission_file.file_blob = ActiveStorage::Blob.new(file_blob_params)

    SubmissionIngestionJob.perform_later(submission_file)

    render jsonapi: submission_file,
           status: :created,
           fields: { submission_files: %i[submission_id rows filename] }
  end

  private

  def file_blob_params
    params.require(:file_blob).permit(:key, :filename, :content_type, :byte_size, :checksum)
  end
end

class SerializableSubmissionFile < JSONAPI::Serializable::Resource
  type 'submission_files'

  attribute :submission_id
  attribute :rows
  attribute :filename
  attribute :temporary_download_url
end

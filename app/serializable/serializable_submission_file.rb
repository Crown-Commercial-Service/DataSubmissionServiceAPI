class SerializableSubmissionFile < JSONAPI::Serializable::Resource
  type 'submission_files'

  attribute :submission_id
end

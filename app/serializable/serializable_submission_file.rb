class SerializableSubmissionFile < JSONAPI::Serializable::Resource
  type 'submission_files'

  attribute :submission_id
  attribute :rows

  attribute :filename do
    @object.file.attachment.filename if @object.file.attached?
  end
end

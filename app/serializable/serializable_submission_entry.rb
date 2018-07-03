class SerializableSubmissionEntry < JSONAPI::Serializable::Resource
  type 'submission_entries'

  attribute :submission_id
  attribute :submission_file_id

  attribute :source
  attribute :data

  attribute :status do
    @object.aasm.current_state
  end
end

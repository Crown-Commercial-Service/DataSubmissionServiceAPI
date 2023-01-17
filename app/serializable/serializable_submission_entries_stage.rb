class SerializableSubmissionEntriesStage < JSONAPI::Serializable::Resource
  type 'submission_entries_stages'

  attribute :submission_id
  attribute :submission_file_id

  attribute :source
  attribute :data

  attribute :validation_errors

  attribute :status do
    @object.aasm.current_state
  end
end

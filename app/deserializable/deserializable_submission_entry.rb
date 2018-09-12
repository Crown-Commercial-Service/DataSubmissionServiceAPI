class DeserializableSubmissionEntry < JSONAPI::Deserializable::Resource
  attribute :entry_type
  attribute :source
  attribute :data
  attribute :status
  attribute :validation_errors
end

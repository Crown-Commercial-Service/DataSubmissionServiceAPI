class DeserializableSubmissionEntry < JSONAPI::Deserializable::Resource
  attribute :source
  attribute :data
  attribute :status
  attribute :validation_errors
end

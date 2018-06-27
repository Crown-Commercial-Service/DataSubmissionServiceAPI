class DeserializableSubmissionEntry < JSONAPI::Deserializable::Resource
  attribute :source
  attribute :data
end

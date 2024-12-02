class SerializableReleaseNote < JSONAPI::Serializable::Resource
  type 'release_notes'

  attributes :header, :body
end
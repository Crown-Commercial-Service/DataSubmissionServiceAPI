class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  attributes :status
end

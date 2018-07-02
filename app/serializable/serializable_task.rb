class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  attributes :status, :framework_id, :supplier_id
end

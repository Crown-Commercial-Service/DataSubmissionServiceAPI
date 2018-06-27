class SerializableFramework < JSONAPI::Serializable::Resource
  type 'frameworks'

  attributes :short_name, :name
end

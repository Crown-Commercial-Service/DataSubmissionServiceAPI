class SerializableFramework < JSONAPI::Serializable::Resource
  type 'frameworks'

  attributes :short_name, :name, :file_key, :file_name
end

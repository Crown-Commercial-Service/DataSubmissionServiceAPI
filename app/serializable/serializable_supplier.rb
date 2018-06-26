class SerializableSupplier < JSONAPI::Serializable::Resource
  type 'suppliers'

  attributes :name
end

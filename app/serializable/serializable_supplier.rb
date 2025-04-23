class SerializableSupplier < JSONAPI::Serializable::Resource
  type 'suppliers'

  attributes :name

  has_many :tasks
end

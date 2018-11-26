class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'
  attributes :multiple_suppliers?, :name, :email
end

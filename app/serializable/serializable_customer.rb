class SerializableCustomer < JSONAPI::Serializable::Resource
  type 'customers'

  attributes :name, :postcode, :urn, :sector
end

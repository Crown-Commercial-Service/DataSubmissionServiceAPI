class SerializableAgreement < JSONAPI::Serializable::Resource
  type 'agreements'

  attributes :framework_id, :supplier_id
end

class SerializableAgreement < JSONAPI::Serializable::Resource
  type 'agreements'

  belongs_to :supplier
  belongs_to :framework

  attributes :framework_id, :supplier_id, :active, :relevant_lots
end

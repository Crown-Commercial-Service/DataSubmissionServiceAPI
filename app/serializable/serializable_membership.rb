class SerializableMembership < JSONAPI::Serializable::Resource
  type 'memberships'

  attributes :user_id, :supplier_id
end

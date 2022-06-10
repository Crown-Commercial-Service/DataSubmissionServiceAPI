class DeserializableCustomerEffortScore < JSONAPI::Deserializable::Resource
  attributes :rating, :comments, :user_id
end
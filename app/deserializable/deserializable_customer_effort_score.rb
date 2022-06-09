class DeserializableCustomerEffortScore < JSONAPI::Deserializable::Resource
  attributes :ratings, :comments, :user_id
end
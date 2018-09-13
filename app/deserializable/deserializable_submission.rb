class DeserializableSubmission < JSONAPI::Deserializable::Resource
  attribute :task_id
  attribute :purchase_order_number
end

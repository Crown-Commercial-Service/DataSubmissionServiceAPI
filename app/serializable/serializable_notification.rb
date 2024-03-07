class SerializableNotification < JSONAPI::Serializable::Resource
  type 'notifications'

  attribute :notification_message
end

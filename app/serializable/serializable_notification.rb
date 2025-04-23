class SerializableNotification < JSONAPI::Serializable::Resource
  type 'notifications'

  attributes :summary, :notification_message
end

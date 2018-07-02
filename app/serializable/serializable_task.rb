class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  attributes :status, :framework_id, :supplier_id
  attributes :description, :due_on
  attributes :period_year, :period_month
end

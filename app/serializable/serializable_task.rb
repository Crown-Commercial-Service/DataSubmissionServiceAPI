class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  has_many :submissions

  attributes :status, :framework_id, :supplier_id
  attributes :description, :due_on
  attributes :period_year, :period_month
end

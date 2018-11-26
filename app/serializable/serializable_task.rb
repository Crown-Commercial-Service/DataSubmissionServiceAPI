class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  has_one :latest_submission
  has_many :submissions
  belongs_to :framework

  attributes :status, :framework_id, :supplier_id, :supplier_name
  attributes :description, :due_on
  attributes :period_year, :period_month
end

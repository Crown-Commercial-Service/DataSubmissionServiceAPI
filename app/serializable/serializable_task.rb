class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  has_one :active_submission
  has_one :latest_submission
  has_many :submissions
  belongs_to :framework

  attributes :status, :framework_id, :supplier_id, :supplier_name
  attributes :description, :due_on
  attributes :period_year, :period_month
  attribute :file_key do
    @object.framework.file_key if @include_file == 'true'
  end
  attribute :file_name do
    @object.framework.file_name if @include_file == 'true'
  end
end

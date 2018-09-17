class SerializableSubmission < JSONAPI::Serializable::Resource
  type 'submissions'

  belongs_to :framework
  belongs_to :task
  has_many :entries
  has_many :files

  attributes :framework_id, :supplier_id, :task_id
  attribute :levy
  attribute :purchase_order_number

  attribute :status do
    @object.aasm.current_state
  end
end

class SerializableSubmission < JSONAPI::Serializable::Resource
  type 'submissions'

  has_many :entries
  has_many :files

  attributes :framework_id, :supplier_id, :task_id

  attribute :status do
    @object.aasm.current_state
  end
end

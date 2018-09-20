class SerializableSubmission < JSONAPI::Serializable::Resource
  type 'submissions'

  belongs_to :framework
  belongs_to :task
  has_many :entries
  has_many :files

  attributes :framework_id, :supplier_id, :task_id
  attribute :management_charge
  attribute :purchase_order_number

  attribute :status do
    submission.aasm.current_state
  end

  attribute :invoice_count do
    submission.entries.invoices.count
  end

  attribute :order_count do
    submission.entries.orders.count
  end

  private

  def submission
    @object
  end
end

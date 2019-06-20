class SerializableSubmission < JSONAPI::Serializable::Resource
  type 'submissions'

  belongs_to :framework
  belongs_to :task
  has_many :files

  attributes :framework_id, :supplier_id, :task_id
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

  attribute :invoice_total_value do
    submission.total_spend
  end

  attribute :order_total_value

  attribute :sheet_errors

  attribute :report_no_business?

  attribute :submitted_at

  attributes :file_key, :filename

  private

  def submission
    @object
  end
end

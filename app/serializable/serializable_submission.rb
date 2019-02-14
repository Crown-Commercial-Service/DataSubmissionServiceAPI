class SerializableSubmission < JSONAPI::Serializable::Resource
  ERRORED_ROW_LIMIT = 10

  type 'submissions'

  belongs_to :framework
  belongs_to :task
  has_many :files

  attributes :framework_id, :supplier_id, :task_id
  attributes :updated_at, :submitted_at
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

  attribute :sheet_errors do
    Hash[submission.sheet_names.map { |sheet_name| [sheet_name, errors_for(sheet_name)] }]
  end

  attribute :invoice_total_value do
    submission.entries.invoices.sum(:total_value)
  end

  attribute :order_total_value do
    submission.entries.orders.sum(:total_value)
  end

  attribute :report_no_business?

  attribute :invoiced? do
    submission.invoice.present?
  end

  private

  def submission
    @object
  end

  def errors_for(sheet_name)
    submission
      .entries
      .sheet(sheet_name)
      .errored
      .ordered_by_row
      .limit(ERRORED_ROW_LIMIT)
      .pluck(:validation_errors)
      .flatten
  end
end

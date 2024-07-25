class SerializableTask < JSONAPI::Serializable::Resource
  type 'tasks'

  has_one :active_submission
  has_one :latest_submission
  has_many :submissions
  belongs_to :framework

  attributes :status, :framework_id, :supplier_id, :supplier_name
  attributes :description, :due_on
  attributes :period_year, :period_month
  attribute :past_submissions do
    if @include_past_submissions
      @object.past_submissions.map do |submission|
        {
          id: submission.id,
          submitted_at: submission.submitted_at,
          submitted_by: submission.submitted_by.email,
          invoice_total: submission.invoice_total,
          file_name: submission.filename,
          invoice_details: submission.invoice_details,
          credit_note_details: submission.credit_note_details
        }
      end
    end
  end
  attribute :file_key do
    @object.framework.file_key if @include_file == 'true'
  end
  attribute :file_name do
    @object.framework.file_name if @include_file == 'true'
  end
end

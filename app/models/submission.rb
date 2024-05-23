class Submission < ApplicationRecord
  ERRORED_ROW_LIMIT = 10

  include AASM

  belongs_to :framework
  belongs_to :supplier
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :submitted_by, class_name: 'User', optional: true
  belongs_to :task

  has_many :files, dependent: :nullify, class_name: 'SubmissionFile'
  has_many :entries, dependent: :nullify, class_name: 'SubmissionEntry'
  has_many :staging_entries, dependent: :nullify, class_name: 'SubmissionEntriesStage'
  has_one :invoice,
          -> { where(reversal: false) },
          dependent: :nullify,
          class_name: 'SubmissionInvoice',
          inverse_of: :submission
  has_one :reversal_invoice,
          -> { where(reversal: true) },
          dependent: :nullify,
          class_name: 'SubmissionInvoice',
          inverse_of: :submission

  aasm do
    state :pending, initial: true
    state :processing
    state :validation_failed
    state :ingest_failed
    state :management_charge_calculation_failed
    state :in_review
    state :completed
    state :replaced

    event :ready_for_review do
      transitions from: %i[pending processing], to: :in_review, guard: :all_entries_valid?
      transitions from: %i[pending processing], to: :validation_failed
    end

    event :reviewed_and_accepted do
      transitions from: :in_review, to: :completed
    end

    event :replace_with_no_business do
      transitions from: :completed, to: :replaced, guard: :replaceable?

      after do |user|
        enqueue_reversal_invoice_creation_job(user) if create_reversal_invoice?
      end
    end

    event :mark_as_replaced do
      transitions from: :completed, to: :replaced

      after do |user|
        enqueue_reversal_invoice_creation_job(user) if create_reversal_invoice?
      end
    end
  end

  def all_entries_valid?
    entries.validated.count == entries.count
  end

  def replaceable?
    !report_no_business?
  end

  def sheet_names
    entries.distinct.pluck(Arel.sql("source->>'sheet'"))
  end

  def report_no_business?
    files.count.zero?
  end

  def agreement
    supplier.agreement_for_framework(framework)
  end

  def management_charge
    self.management_charge_total ||= entries.invoices.sum(:management_charge)
  end

  def total_spend
    self.invoice_total ||= entries.invoices.sum(:total_value)
  end

  def order_total_value
    entries.orders.sum(:total_value)
  end

  def sheet_errors
    sheet_names.index_with { |sheet_name| errors_for(sheet_name) }
  end

  def file_key
    files.first&.file_key
  end

  def filename
    files.first&.filename
  end

  def invoice_details
    return unless invoice

    call_workday(invoice.workday_reference)
  end

  def credit_note_details
    return unless reversal_invoice

    call_workday(reversal_invoice.workday_reference)
  end

  def call_workday(workday_reference)
    Workday::CustomerInvoice.new(workday_reference).invoice_details
  rescue Workday::ConnectionError
    nil
  end

  private

  def enqueue_reversal_invoice_creation_job(user)
    SubmissionReversalInvoiceCreationJob.perform_later(self, user)
  end

  def create_reversal_invoice?
    !report_no_business? && management_charge != 0 && ENV['SUBMIT_INVOICES']
  end

  def errors_for(sheet_name)
    entries
      .sheet(sheet_name)
      .errored
      .ordered_by_row
      .limit(ERRORED_ROW_LIMIT)
      .pluck(:validation_errors)
      .flatten
  end
end

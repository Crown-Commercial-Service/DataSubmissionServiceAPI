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
    state :in_review
    state :completed
    state :replaced

    event :ready_for_review do
      transitions from: %i[pending processing], to: :in_review, guard: :all_entries_valid?
      transitions from: %i[pending processing], to: :validation_failed
    end

    event :reviewed_and_accepted do
      transitions from: :in_review, to: :completed, guard: :all_entries_valid?

      error do |e|
        errors.add(:aasm_state, message: e.message)
      end
    end

    event :replace_with_no_business do
      transitions from: :completed, to: :replaced, guard: :replaceable?

      after do |*user|
        enqueue_reversal_invoice_creation_job(user) if create_reversal_invoice?
      end
    end

    event :mark_as_replaced do
      transitions from: :completed, to: :replaced

      after do |*user|
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
    entries.invoices.sum(:management_charge)
  end

  def total_spend
    entries.invoices.sum(:total_value)
  end

  def order_total_value
    entries.orders.sum(:total_value)
  end

  def sheet_errors
    Hash[sheet_names.map { |sheet_name| [sheet_name, errors_for(sheet_name)] }]
  end

  private

  def enqueue_reversal_invoice_creation_job(user)
    SubmissionReversalInvoiceCreationJob.perform_later(self, user)
  end

  def create_reversal_invoice?
    invoice.present? && ENV['SUBMIT_INVOICES']
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

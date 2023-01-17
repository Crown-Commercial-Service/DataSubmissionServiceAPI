class SubmissionEntry < ApplicationRecord
  include AASM

  TYPES = %w[invoice order other].freeze

  belongs_to :submission
  belongs_to :submission_file, optional: true
  belongs_to :customer, primary_key: :urn, foreign_key: :customer_urn, optional: true, inverse_of: :submission_entries
  has_one :framework, through: :submission

  validates :data, presence: true
  validates :entry_type, inclusion: { in: TYPES }, allow_blank: true

  scope :sheet, ->(sheet_name) { where("source->>'sheet' = ?", sheet_name) }
  scope :invoices, -> { where(entry_type: 'invoice') }
  scope :orders, -> { where(entry_type: 'order') }
  scope :others, -> { where(entry_type: 'other') }
  scope :ordered_by_row, -> { order(Arel.sql("(source->>'row')::integer ASC")) }
  scope :sector, ->(sector) { joins(:customer).merge(Customer.where(sector: sector)) }
  scope :central_government, -> { sector(Customer.sectors[:central_government]) }
  scope :wider_public_sector, -> { sector(Customer.sectors[:wider_public_sector]) }

  aasm do
    state :pending, initial: true
    state :validated
    state :errored
  end

  def validate_against!(sheet_definition)
    entry_data = sheet_definition.new(self)

    if entry_data.valid?
      self.aasm_state = :validated
      self.validation_errors = {}
    else
      self.aasm_state = :errored
      self.validation_errors = validation_errors_hash(entry_data.errors)
    end
  end

  private

  def validation_errors_hash(errors)
    errors.to_hash.map do |field, messages|
      {
        message: messages.to_sentence,
        location: {
          column: field,
          row: source['row'],
        },
      }
    end
  end
end

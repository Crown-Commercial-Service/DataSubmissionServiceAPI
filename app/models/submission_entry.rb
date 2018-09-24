class SubmissionEntry < ApplicationRecord
  include AASM

  belongs_to :submission
  belongs_to :submission_file, optional: true

  validates :data, presence: true
  validates :entry_type, inclusion: { in: %w[invoice order] }, allow_blank: true

  scope :sheet, ->(sheet_name) { where("source->>'sheet' = ?", sheet_name) }
  scope :invoices, -> { where(entry_type: 'invoice') }
  scope :orders, -> { where(entry_type: 'order') }
  scope :ordered_by_row, -> { order(Arel.sql("(source->>'row')::integer ASC")) }
  scope :sector, lambda { |sector|
    joins("INNER JOIN customers ON customers.urn = CAST(submission_entries.data->>'Customer URN' AS INTEGER)")
      .where('customers.sector = ?', sector)
  }
  scope :central_government, -> { sector(Customer.sectors[:central_government]) }
  scope :wider_public_sector, -> { sector(Customer.sectors[:wider_public_sector]) }

  aasm do
    state :pending, initial: true
    state :validated
    state :errored
  end
end

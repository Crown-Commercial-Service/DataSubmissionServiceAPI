class SubmissionEntry < ApplicationRecord
  include AASM

  belongs_to :submission
  belongs_to :submission_file, optional: true

  validates :data, presence: true

  scope :sheet, ->(sheet_name) { where("source->>'sheet' = ?", sheet_name) }

  aasm do
    state :pending, initial: true
    state :validated
    state :errored
  end
end

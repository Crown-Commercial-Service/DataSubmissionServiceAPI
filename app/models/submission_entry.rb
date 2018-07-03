class SubmissionEntry < ApplicationRecord
  include AASM

  belongs_to :submission
  belongs_to :submission_file, optional: true

  validates :data, presence: true

  aasm do
    state :pending, initial: true
    state :validated
    state :errored
  end
end

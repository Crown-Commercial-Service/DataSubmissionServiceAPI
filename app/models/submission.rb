class Submission < ApplicationRecord
  include AASM

  belongs_to :framework
  belongs_to :supplier
  belongs_to :task

  has_many :files, dependent: :nullify, class_name: 'SubmissionFile'
  has_many :entries, dependent: :nullify, class_name: 'SubmissionEntry'

  aasm do
    state :pending, initial: true
    state :processing
    state :in_review
    state :completed
    state :rejected

    event :ready_for_review do
      transitions from: %i[pending processing], to: :in_review
    end
  end
end

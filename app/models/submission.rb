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
    state :complete
    state :rejected
  end
end

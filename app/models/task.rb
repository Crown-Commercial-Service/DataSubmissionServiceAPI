class Task < ApplicationRecord
  include AASM

  aasm column: 'status' do
    state :draft
    state :unstarted, intial: true
    state :in_progress
    state :in_review
    state :complete
    state :cancelled
  end

  validates :status, presence: true

  belongs_to :framework, optional: true
  belongs_to :supplier

  has_many :submissions, dependent: :nullify
end

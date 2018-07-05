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

  def self.for_user_id(user_id)
    supplier_ids = Membership
                   .where(user_id: user_id)
                   .pluck(:supplier_id)

    where(supplier_id: supplier_ids)
  end
end

class Task < ApplicationRecord
  include AASM

  aasm column: 'status' do
    state :unstarted, initial: true
    state :in_progress
    state :completed

    event :completed do
      transitions from: %i[unstarted in_progress], to: :completed
    end
  end

  validates :status, presence: true

  belongs_to :framework, optional: true
  belongs_to :supplier

  has_many :submissions, dependent: :nullify
  has_one :latest_submission, -> { order(created_at: :desc) }, inverse_of: :task, class_name: 'Submission'

  def self.for_auth_id(user_auth_id)
    user = User.find_by!(auth_id: user_auth_id)
    supplier_ids = user.memberships.pluck(:supplier_id)

    where(supplier_id: supplier_ids)
  end

  def file_no_business!
    transaction do
      completed!
      submissions.create!(framework: framework, supplier: supplier, aasm_state: :completed)
    end
  end

  delegate :name, to: :supplier, prefix: true
end

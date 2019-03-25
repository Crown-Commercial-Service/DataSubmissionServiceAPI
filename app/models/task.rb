class Task < ApplicationRecord
  include AASM

  aasm column: 'status' do
    state :unstarted, initial: true
    state :in_progress
    state :completed
    state :correcting

    event :completed do
      transitions from: %i[unstarted in_progress correcting completed], to: :completed
    end

    event :cancel_correction do
      before do
        destroy_incomplete_correction_submissions if correcting?
      end
      transitions from: :correcting, to: :completed
    end
  end

  scope :incomplete, -> { where.not(status: 'completed') }

  validates :status, presence: true

  belongs_to :framework, optional: true
  belongs_to :supplier

  has_many :submissions, dependent: :nullify

  delegate :name, to: :supplier, prefix: true

  completed_or_latest_scope = lambda do
    order(Arel.sql("CASE submissions.aasm_state WHEN 'completed' THEN 1 ELSE 2 END"), created_at: :desc)
  end
  has_one :active_submission, completed_or_latest_scope, class_name: 'Submission', inverse_of: :task
  has_one :latest_submission, -> { order(created_at: :desc) }, class_name: 'Submission', inverse_of: :task

  def file_no_business!(user)
    transaction do
      completed!
      submissions.create!(
        framework: framework,
        supplier: supplier,
        created_by: user,
        submitted_by: user,
        submitted_at: Time.zone.now,
        aasm_state: :completed
      )
    end
  end

  def period_date
    Date.new(period_year, period_month)
  end

  # Returns true when the task is yet to be completed by the Supplier
  def incomplete?
    !completed? && !correcting?
  end

  def destroy_incomplete_correction_submissions
    transaction do
      submissions.where('created_at > ?', active_submission.created_at).find_each do |submission|
        submission.entries.destroy_all
        submission.files.destroy_all
        submission.destroy
      end
    end
  end
end

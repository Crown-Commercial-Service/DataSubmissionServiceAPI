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
  # rubocop:disable Metrics/LineLength
  scope :within_date_range, lambda { |date_range|
    start_date, end_date = date_range
    where("to_date(period_year || '-' || LPAD(period_month::text, 2, '0') || '-01', 'YYYY-MM-DD') BETWEEN ? AND ?", start_date, end_date)
  }

  scope :latest_submission_with_state, lambda { |status_param|
    joins(:submissions)
      .where('submissions.created_at = (SELECT MAX(submissions.created_at) FROM submissions WHERE submissions.task_id = tasks.id)')
      .where('submissions.aasm_state IN (?)', status_param)
  }
  # rubocop:enable Metrics/LineLength

  validates :status, presence: true
  validates :period_year, presence: true
  validates :period_month,
            presence: true,
            uniqueness: { scope: %i[supplier_id framework_id period_year], message: 'This task already exists' }
  validates :framework_id, presence: true
  validates :due_on, presence: true
  validate :not_a_future_task

  before_validation :set_due_on, on: :create

  belongs_to :framework
  belongs_to :supplier

  has_many :submissions, dependent: :nullify

  delegate :name, to: :supplier, prefix: true

  completed_or_latest_scope = lambda do
    order(Arel.sql("CASE submissions.aasm_state WHEN 'completed' THEN 1 ELSE 2 END"), created_at: :desc)
  end
  has_one :active_submission, completed_or_latest_scope, class_name: 'Submission', inverse_of: :task,
dependent: :nullify
  has_one :latest_submission, lambda {
                                order(created_at: :desc)
                              }, class_name: 'Submission', inverse_of: :task, dependent: :nullify

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

  def past_submissions
    submissions.where(aasm_state: :replaced).order(updated_at: :desc)
  end

  # Returns true when the task is yet to be completed by the Supplier
  def incomplete?
    !completed? && !correcting?
  end

  def destroy_incomplete_correction_submissions
    transaction do
      submissions.where('created_at > ?', active_submission.created_at).find_each do |submission|
        submission.entries.destroy_all
        submission.staging_entries.destroy_all
        submission.files.destroy_all
        submission.destroy
      end
    end
  end

  private

  def set_due_on
    return if period_year.blank? || period_month.blank?

    self.due_on ||= Task::SubmissionWindow.new(period_year, period_month).due_date
  end

  def not_a_future_task
    return if period_year.blank? || period_month.blank?

    task_period = Date.new(period_year, period_month)
    errors.add(:base, 'Task cannot be in the future') unless task_period < Time.zone.today.beginning_of_month
  end
end

class SubmissionStatusUpdate
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    return unless all_entries_ingested? && no_entries_pending?

    all_entries_validated? ? calculate_management_charge : submission.ready_for_review!
  end

  private

  def all_entries_ingested?
    submission.files.sum(&:rows) == submission.entries.count
  end

  def no_entries_pending?
    submission.entries.pending.none?
  end

  def all_entries_validated?
    submission.entries.validated.count == submission.entries.count
  end

  def calculate_management_charge
    SubmissionManagementChargeCalculationJob.perform_later(submission)
  end
end

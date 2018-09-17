class SubmissionStatusUpdate
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    return unless submission.entries.any?

    trigger_management_charge_calculation if all_entries_valid?
    transition_to_in_review if no_entries_pending? && some_entries_errored?
  end

  private

  def all_entries_valid?
    submission.entries.validated.count == submission.entries.count
  end

  def transition_to_in_review
    submission.ready_for_review!
  end

  def no_entries_pending?
    submission.entries.pending.none?
  end

  def some_entries_errored?
    submission.entries.errored.any?
  end

  def trigger_management_charge_calculation
    AWSLambdaService.new(submission_id: submission.id).trigger
  end
end

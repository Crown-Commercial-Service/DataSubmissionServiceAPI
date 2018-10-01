class SubmissionStatusUpdate
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    return unless submission.entries.any?

    submission.ready_for_review! if no_entries_pending?
  end

  private

  def no_entries_pending?
    submission.entries.pending.none?
  end
end

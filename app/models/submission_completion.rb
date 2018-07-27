class SubmissionCompletion
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    return unless all_entries_valid?

    Task.transaction do
      Submission.transaction do
        submission.reviewed_and_accepted!
        submission.task.completed!
      end
    end
  end

  private

  def all_entries_valid?
    submission.entries.validated.count == submission.entries.count
  end
end

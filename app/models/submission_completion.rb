class SubmissionCompletion
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    submission.reviewed_and_accepted! do
      submission.task.completed!
    end

    submission
  end
end

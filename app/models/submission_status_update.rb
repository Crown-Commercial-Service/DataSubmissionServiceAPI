class SubmissionStatusUpdate
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    return unless submission.entries.any?

    trigger_levy_calculation if all_entries_valid?
  end

  private

  def all_entries_valid?
    submission.entries.validated.count == submission.entries.count
  end

  def trigger_levy_calculation
    AWSLambdaService.new(submission_id: submission.id).trigger
  end
end

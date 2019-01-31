class SubmissionCompletion
  attr_reader :submission, :user

  def initialize(submission, user)
    @submission = submission
    @user = user
  end

  def perform!
    submission.reviewed_and_accepted! do
      submission.submitted_by = user
      submission.submitted_at = Time.zone.now
      submission.save
      submission.task.completed!
    end

    SubmissionInvoiceCreationJob.perform_later(submission) if !submission.report_no_business? && ENV['SUBMIT_INVOICES']

    submission
  end
end

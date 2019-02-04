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

    SubmissionInvoiceCreationJob.perform_later(submission) if create_invoice_for?(submission)

    submission
  end

  private

  def create_invoice_for?(submission)
    !submission.report_no_business? && submission.total_spend != 0 && ENV['SUBMIT_INVOICES']
  end
end

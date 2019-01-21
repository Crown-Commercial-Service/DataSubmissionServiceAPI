class SubmissionCompletion
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    submission.reviewed_and_accepted! do
      submission.task.completed!
    end

    SubmissionInvoiceCreationJob.perform_later(submission) if !submission.report_no_business? && ENV['SUBMIT_INVOICES']

    submission
  end
end

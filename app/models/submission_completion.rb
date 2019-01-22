class SubmissionCompletion
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def perform!
    submission.reviewed_and_accepted! do
      submission.task.completed!
    end

    if !submission.report_no_business? && ENV['SUBMIT_INVOICES']
      SubmissionInvoiceCreationJob.perform_later(submission.id)
    end

    submission
  end
end

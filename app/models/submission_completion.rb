class SubmissionCompletion
  attr_reader :submission, :user

  def initialize(submission, user)
    @submission = submission
    @user = user
  end

  def perform!
    ActiveRecord::Base.transaction do
      mark_completed_submission_as_replaced!(user)

      submission.reviewed_and_accepted! do
        submission.submitted_by = user
        submission.submitted_at = Time.zone.now
        submission.save
        submission.task.completed!
      end
    end

    SubmissionInvoiceCreationJob.perform_later(submission) if create_invoice_for?(submission)

    submission
  end

  private

  def create_invoice_for?(submission)
    !submission.report_no_business? && submission.management_charge != 0 && ENV['SUBMIT_INVOICES']
  end

  def mark_completed_submission_as_replaced!(user)
    submission.task.submissions.find_by(aasm_state: 'completed')&.mark_as_replaced!(user)
  end
end

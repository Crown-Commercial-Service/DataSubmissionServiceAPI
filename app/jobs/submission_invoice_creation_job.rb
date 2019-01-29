class SubmissionInvoiceCreationJob < ApplicationJob
  def perform(submission)
    raise "Submission #{submission.id} already has an invoice." if submission.invoice.present?

    workday_reference = Workday::SubmitCustomerInvoiceRequest.new(submission).perform
    submission.create_invoice!(workday_reference: workday_reference)
  end
end

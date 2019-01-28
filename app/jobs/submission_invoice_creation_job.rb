class SubmissionInvoiceCreationJob < ApplicationJob
  def perform(submission)
    raise "Submission #{submission.id} already has an invoice." if submission.invoice.present?

    workday_reference = if submission.management_charge.negative?
                          Workday::SubmitCustomerInvoiceAdjustmentRequest.new(submission).perform
                        else
                          Workday::SubmitCustomerInvoiceRequest.new(submission).perform
                        end
    submission.create_invoice!(workday_reference: workday_reference)
  end
end

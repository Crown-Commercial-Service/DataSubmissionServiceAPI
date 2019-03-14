class SubmissionReversalInvoiceCreationJob < ApplicationJob
  ## Used to generate a reversal of the original Workday invoice or invoice adjustment
  ## If the original management charge was negative,
  # the original request was an invoice adjustment,
  # and it needs to be cancelled out by an invoice
  ## If the original management charge was positive,
  # the original request was an invoice,
  # and it needs to be cancelled out by an invoice adjustment
  def perform(submission)
    raise "Submission #{submission.id} already has a reversal invoice." if submission.reversal_invoice.present?

    workday_reference = if submission.management_charge.negative?
                          Workday::SubmitReversalInvoice.new(submission).perform
                        else
                          Workday::SubmitReversalInvoiceAdjustment.new(submission).perform
                        end
    submission.create_reversal_invoice!(workday_reference: workday_reference)
  end
end

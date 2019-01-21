class SubmissionInvoiceCreationJob < ApplicationJob
  def perform(submission)
    Workday::SubmitCustomerInvoiceRequest.new(submission).perform
  end
end

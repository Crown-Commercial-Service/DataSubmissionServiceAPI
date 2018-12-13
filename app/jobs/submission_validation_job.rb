class SubmissionValidationJob < ApplicationJob
  def perform(submission)
    submission.entries.pending.find_each(&:validate_against_framework_definition!)

    if submission.entries.errored.any?
      submission.ready_for_review!
    else
      SubmissionManagementChargeCalculationJob.perform_later(submission)
    end
  end
end

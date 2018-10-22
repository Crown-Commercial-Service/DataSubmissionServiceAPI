##
# Calculates the management charge on all the submission's invoice entries and
# marks it as ready for review
#
class SubmissionManagementChargeCalculationJob < ApplicationJob
  def perform(submission)
    framework_definition = submission.framework.definition

    submission.entries.invoices.find_each do |entry|
      entry.update! management_charge: framework_definition.management_charge(entry.total_value)
    end

    submission.ready_for_review!
  end
end

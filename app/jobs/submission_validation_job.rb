class SubmissionValidationJob < ApplicationJob
  def perform(submission)
    framework_definition = submission.framework.definition

    submission.entries.pending.find_each do |entry|
      sheet_definition = framework_definition.for_entry_type(entry.entry_type)
      entry_data = sheet_definition.new_from_params(entry.data)

      if entry_data.valid?
        entry.aasm_state = :validated
      else
        entry.aasm_state = :errored
        entry.validation_errors = entry_data.errors.details
      end

      entry.save!
    end

    if submission.entries.errored.any?
      submission.ready_for_review!
    else
      SubmissionManagementChargeCalculationJob.perform_later(submission)
    end
  end
end

class SubmissionValidationJob < ApplicationJob
  def perform(submission, calculation_job = SubmissionManagementChargeCalculationJob)
    framework_definition = submission.framework.definition

    submission.entries.pending.each do |entry|
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

    calculation_job.perform_later(submission)
  end
end

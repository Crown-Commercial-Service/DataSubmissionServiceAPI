##
# Calculates the management charge on all the submission's invoice entries and
# marks it as ready for review
#
class SubmissionManagementChargeCalculationJob < ApplicationJob
  class DefinitionSourceChanged < StandardError; end

  discard_on(DefinitionSourceChanged) do |job, _exception|
    handle_definition_source_changed(job)
  end

  def perform(submission, definition_source_at_enqueue_time)
    @submission = submission
    @definition_source_at_enqueue_time = definition_source_at_enqueue_time

    ensure_definition_source_unchanged_since_enqueue
    calculate
  end

  private

  def framework
    @framework ||= @submission.framework
  end

  def ensure_definition_source_unchanged_since_enqueue
    current_source = framework.definition_source
    return if @definition_source_at_enqueue_time == current_source

    Rollbar.error('Definition source has changed since job was enqueued.'\
                  "Previous source: #{@definition_source_at_enqueue_time}. Current source: #{current_source}")
    raise DefinitionSourceChanged
  end

  def calculate
    framework_definition = framework.definition

    @submission.entries.invoices.find_each do |entry|
      entry.update! management_charge: framework_definition.calculate_management_charge(entry)
    end

    @submission.ready_for_review!
  end

  class << self
    private

    def handle_definition_source_changed(job)
      submission = job.arguments.first

      submission.update!(aasm_state: :management_charge_calculation_failed)
    end
  end
end

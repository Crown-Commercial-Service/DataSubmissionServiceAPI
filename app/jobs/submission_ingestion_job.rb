class SubmissionIngestionJob < ApplicationJob
  discard_on(Ingest::Loader::MissingInvoiceColumns) do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  discard_on(Ingest::Loader::MissingOrderColumns) do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  def perform(submission_file)
    orchestrator = Ingest::Orchestrator.new(submission_file)
    orchestrator.perform
  end

  def self.handle_unretryable_job_failure(job, exception)
    submission_file = job.arguments.first

    Rails.logger.info "Halted ingest due to #{exception.class}: #{exception.message}"

    submission_file.submission.update!(aasm_state: :ingest_failed)
  end
end

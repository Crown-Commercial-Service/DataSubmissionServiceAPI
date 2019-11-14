class SubmissionIngestionJob < ApplicationJob
  class IngestFailed < StandardError; end

  queue_as :ingest

  discard_on(Ingest::Loader::MissingInvoiceColumns) do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  discard_on(Ingest::Loader::MissingOrderColumns) do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  discard_on(Ingest::Converter::UnreadableFile) do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  discard_on IngestFailed

  def perform(submission_file)
    raise IngestFailed if submission_file.submission.ingest_failed?

    orchestrator = Ingest::Orchestrator.new(submission_file)
    orchestrator.perform
  end

  def self.handle_unretryable_job_failure(job, exception)
    submission_file = job.arguments.first

    Rails.logger.info "Halted ingest due to #{exception.class}: #{exception.message}"

    submission_file.submission.update!(aasm_state: :ingest_failed)
  end
end

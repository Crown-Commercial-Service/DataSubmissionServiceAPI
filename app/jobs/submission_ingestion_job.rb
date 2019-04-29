class SubmissionIngestionJob < ApplicationJob
  def perform(submission_file)
    orchestrator = Ingest::Orchestrator.new(submission_file)
    orchestrator.perform
  end
end

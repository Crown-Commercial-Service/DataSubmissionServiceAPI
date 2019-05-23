module Ingest
  class Orchestrator
    ##
    # Given a +submission_file+ perform the complete ingest process
    #
    # This includes updating the +submission+ model with the correct
    # states throughout the process
    def initialize(submission_file)
      @submission_file = submission_file
      @submission = @submission_file.submission
      @framework = @submission.framework
    end

    def perform
      Rails.logger.tagged(logger_tags) do
        @submission.update!(aasm_state: :processing)
        SubmissionEntry.where(submission_file_id: @submission_file.id).delete_all

        downloader = AttachedFileDownloader.new(@submission_file.file)
        downloader.download!

        converter = Ingest::Converter.new(downloader.temp_file.path)
        @submission_file.update!(rows: converter.rows)

        loader = Ingest::Loader.new(converter, @submission_file)
        loader.perform

        downloader.cleanup!

        calculate_management_charge_if_valid
      end
    end

    private

    def logger_tags
      [
        @submission_file.id,
        @framework.short_name,
        'ingest'
      ]
    end

    def calculate_management_charge_if_valid
      if @submission.entries.errored.none?
        Rails.logger.info 'All rows valid, calculating management charge'
        SubmissionManagementChargeCalculationJob.perform_later(@submission)
      else
        Rails.logger.info 'Some rows had validation errors'
        @submission.ready_for_review!
      end
    end
  end
end

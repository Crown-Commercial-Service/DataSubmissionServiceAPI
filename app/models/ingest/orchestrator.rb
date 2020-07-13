module Ingest
  class Orchestrator
    class MissingSheets < StandardError; end

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
        raise_when_sheets_missing(converter)

        @submission_file.update!(rows: total_row_count(converter))

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

    def raise_when_sheets_missing(converter)
      required_entry_types = Set.new(@framework.definition.defined_entry_types)
      found_entry_types = Set.new(SubmissionEntry::TYPES.map { |type| converter.rows_for(type).type })
      diff = required_entry_types.difference(found_entry_types)
      return if diff.empty?

      raise MissingSheets, "Sheet(s) missing from submission file: #{diff.to_a.to_sentence}"
    end

    def calculate_management_charge_if_valid
      if @submission.entries.errored.none?
        Rails.logger.info 'All rows valid, calculating management charge'
        SubmissionManagementChargeCalculationJob.perform_later(@submission, @framework.definition_source)
      else
        Rails.logger.info 'Some rows had validation errors'
        @submission.ready_for_review!
      end
    end

    def total_row_count(converter)
      @total_row_count ||= @framework.definition.defined_entry_types.reduce(0) do |total, type|
        total + converter.rows_for(type).row_count
      end
    end
  end
end

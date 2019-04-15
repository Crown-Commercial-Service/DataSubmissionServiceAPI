require 'open3'
require 'English'

module Ingest
  ##
  # Given a +submission_file+, fetch its attached spreadsheet using curl,
  # exposing the local path to the downloaded attachment as +temp_file+.
  class SubmissionFileDownloader
    attr_reader :temp_file, :submission_file

    def initialize(submission_file)
      @submission_file = submission_file
      @url = @submission_file.file.service_url
      @extension = @submission_file.file.filename.extension
      @temp_file = "/tmp/#{@submission_file.id}.#{@extension}"
      @status = OpenStruct.new(success?: false)
    end

    def perform
      command = "curl -L \"#{@url}\" > \"#{@temp_file}\""

      Open3.popen3(command) do |_in, _out, _err, thread|
        Rails.logger.info "Fetching file ##{@submission_file.id} using curl"
        Rails.logger.info "Command completed with status: #{thread.value}"
      end

      @status = $CHILD_STATUS
    end

    def completed?
      File.exist?(@temp_file) && @status.success?
    end
  end
end

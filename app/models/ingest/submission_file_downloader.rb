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
    end

    def perform
      command = "curl -L \"#{@url}\" > \"#{@temp_file}\""
      runner = Ingest::CommandRunner.new(command).run!
      @successful = runner.successful?
    end

    def completed?
      File.exist?(@temp_file) && @successful
    end
  end
end

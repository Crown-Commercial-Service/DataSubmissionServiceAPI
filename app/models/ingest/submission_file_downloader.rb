require 'open3'
require 'English'

module Ingest
  ##
  # Given a +submission_file+, fetch its attached spreadsheet using curl.
  #
  # Returns a +Download+ object that exposes the local path to the
  # downloaded attachment as +temp_file+ and a boolean +downloaded?+
  # which is true when the file downloaded completed successfully
  class SubmissionFileDownloader
    Download = Struct.new(:temp_file, :successful?) do
      def downloaded?
        File.exist?(temp_file) && successful?
      end
    end

    def initialize(submission_file)
      @submission_file = submission_file
    end

    def perform
      url = @submission_file.file.service_url
      extension = @submission_file.file.filename.extension.downcase
      temp_file = "/tmp/#{@submission_file.id}.#{extension}"

      command = "curl -L \"#{url}\" > \"#{temp_file}\""
      runner = Ingest::CommandRunner.new(command).run!

      Download.new(temp_file, runner.successful?)
    end
  end
end

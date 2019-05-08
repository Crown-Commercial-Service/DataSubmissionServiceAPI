require 'aws-sdk-s3'

module Ingest
  ##
  # Given a +submission_file+, fetch its attached spreadsheet using curl.
  #
  # Returns a +Download+ object that exposes the local path to the
  # downloaded attachment as +temp_file+ and a boolean +downloaded?+
  # which is true when the file downloaded completed successfully
  class SubmissionFileDownloader
    include ActiveStorage::Downloading

    attr_reader :blob

    Download = Struct.new(:temp_file, :successful?) do
      def downloaded?
        File.exist?(temp_file) && successful?
      end
    end

    def initialize(submission_file)
      @submission_file = submission_file
    end

    def perform
      extension = @submission_file.file.filename.extension.downcase
      temp_file = "/tmp/#{@submission_file.id}.#{extension}"
      file = File.open(temp_file, 'w')

      begin
        success = true

        # download_blob_to requires @blob to be set in order to work
        @blob = @submission_file.file.blob

        # This method comes from ActiveStorage::Downloading
        download_blob_to(file)
      rescue Aws::S3::Errors::ServiceError, ArgumentError => e
        Rollbar.error(e)
        success = false
      ensure
        file.close
      end

      Download.new(temp_file, success)
    end
  end
end

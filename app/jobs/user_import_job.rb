require 'tempfile'
require 'aws-sdk-s3'

class UserImportJob < ApplicationJob
  retry_on Aws::S3::Errors::ServiceError
  discard_on Import::Users::InvalidSalesforceId do |job, _error|
    job.arguments.first.update!(aasm_state: :failed)
  end

  discard_on Import::Users::InvalidFormat do |job, _error|
    job.arguments.first.update!(aasm_state: :failed)
  end

  def perform(bulk_user_upload)
    downloader = AttachedFileDownloader.new(bulk_user_upload.csv_file)
    downloader.download!

    Rollbar.info("Bulk user import started for: #{downloader.temp_file.path}")

    Import::Users.new(downloader.temp_file.path).run 
    
    bulk_user_upload.update!(aasm_state: :processed)
    Rollbar.info("Bulk user import completed for: #{downloader.temp_file.path}")

    downloader.temp_file.close
    downloader.temp_file.unlink
    downloader.delete_object
  end
end

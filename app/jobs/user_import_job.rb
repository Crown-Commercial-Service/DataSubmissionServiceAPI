require 'tempfile'
require 'aws-sdk-s3'

class UserImportJob < ApplicationJob
  retry_on Aws::S3::Errors::ServiceError

  discard_on Import::Users::InvalidSalesforceId do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  discard_on Aws::S3::Errors::NoSuchKey do |job, exception|
    handle_unretryable_job_failure(job, exception)
  end

  def perform(user_list_key)
    Rails.logger.info "Bulk user import started for: #{user_list_key}"

    temp_file = Tempfile.new(user_list_key)
    temp_file.binmode

    begin
      s3_client.get_object({ bucket: bucket, key: user_list_key }, target: temp_file)
      Import::Users.new(temp_file).run
    ensure
      temp_file.close
      temp_file.unlink
    end

    Rails.logger.info "Bulk user import completed for: #{user_list_key}"
    s3_client.delete_object(bucket: bucket, key: user_list_key)
  end

  def self.handle_unretryable_job_failure(job, exception)
    user_list_key = job.arguments.first
    Rollbar.info "Bulk user import failed for '#{user_list_key}': #{exception.message}"
    true
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: ENV['AWS_S3_REGION'])
  end

  def bucket
    ENV.fetch('AWS_S3_BUCKET')
  end
end

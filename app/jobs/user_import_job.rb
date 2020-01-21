require 'tempfile'
require 'aws-sdk-s3'

class UserImportJob < ApplicationJob
  retry_on Aws::S3::Errors::ServiceError
  discard_on Import::Users::InvalidSalesforceId

  def perform(user_list_key)
    temp_file = Tempfile.new(user_list_key)
    temp_file.binmode

    s3_client.get_object({ bucket: bucket, key: user_list_key }, target: temp_file)

    Rollbar.info("Bulk user import started for: #{user_list_key}")
    Import::Users.new(temp_file).run
  ensure
    temp_file.close
    temp_file.unlink
    s3_client.delete_object(bucket: bucket, key: user_list_key)
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: ENV['AWS_S3_REGION'])
  end

  def bucket
    ENV.fetch('AWS_S3_BUCKET')
  end
end

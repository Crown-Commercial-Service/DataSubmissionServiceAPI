require 'aws-sdk-s3'
require 'tmpdir'

class UploadUserList
  class UploadError < StandardError
    def message
      'Uploading the user list to S3 failed.'
    end
  end

  def initialize(user_list_path)
    @user_list_path = user_list_path
  end

  def call
    csv_key = "#{SecureRandom.urlsafe_base64}-#{@user_list_path.gsub(%r{.*?/}, '')}"

    s3 = Aws::S3::Resource.new(region: region)
    obj = s3.bucket(bucket).object(csv_key)
    raise UploadError unless obj.upload_file(@user_list_path)

    csv_key
  end

  private

  def bucket
    ENV.fetch('AWS_S3_BUCKET')
  end

  def region
    ENV.fetch('AWS_S3_REGION')
  end
end

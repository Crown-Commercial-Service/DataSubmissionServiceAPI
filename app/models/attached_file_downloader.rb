require 'aws-sdk-s3'
require 'tempfile'

class AttachedFileDownloader
  attr_reader :temp_file

  def initialize(object)
    @object = object

    raise 'Not an ActiveStorage::Attached::One' unless @object.is_a?(ActiveStorage::Attached::One)
  end

  def download!
    extension = @object.filename.extension.downcase
    @temp_file = Tempfile.new([@object.record.class.name, ".#{extension}"])
    @temp_file.binmode

    begin
      s3_client.get_object({ bucket: bucket, key: key }, target: @temp_file)
    rescue Aws::S3::Errors, ArgumentError
      @temp_file.close
      @temp_file.unlink

      raise
    end

    true
  end

  def cleanup!
    @temp_file.close
    @temp_file.unlink
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: ENV['AWS_S3_REGION'])
  end

  def bucket
    ENV.fetch('AWS_S3_BUCKET')
  end

  def key
    @object.attachment.key
  end
end

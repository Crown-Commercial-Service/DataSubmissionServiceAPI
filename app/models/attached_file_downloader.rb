require 'aws-sdk-s3'
require 'tempfile'

class AttachedFileDownloader
  include ActiveStorage::Downloading

  attr_reader :blob, :temp_file

  def initialize(object)
    @object = object

    raise 'Not an ActiveStorage::Attached::One' unless @object.is_a?(ActiveStorage::Attached::One)
  end

  def download!
    extension = @object.filename.extension.downcase
    @temp_file = Tempfile.new([@object.record.class.name, '.' + extension])

    begin
      # download_blob_to requires @blob to be set in order to work
      @blob = @object.blob

      # This method comes from ActiveStorage::Downloading
      download_blob_to(@temp_file)
    rescue Aws::S3::Errors, ArgumentError
      @temp_file.close
      @temp_file.unlink

      raise
    end

    true
  end
end

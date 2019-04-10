require 'aws-sdk-s3'

module Export
  class S3Upload
    # This should be set to true in TEST mode to enable AWS SDK response stubbing
    cattr_accessor :test_mode

    attr_reader :file_map, :logger

    def initialize(file_map, logger = Rails.logger)
      @file_map = file_map
      @logger = logger
    end

    def perform
      file_map.each_pair { |filename, file| upload(filename, file) }
    end

    def client
      @client ||= Aws::S3::Client.new(client_config)
    end

    private

    def upload(filename, file)
      logger.info "Uploading #{filename} to #{bucket_name} on S3"
      client.put_object(body: file, key: filename, bucket: bucket_name)
    end

    def bucket_name
      ENV['AWS_S3_EXPORT_BUCKET']
    end

    def client_config
      if test_mode
        { stub_responses: true }
      else
        {
          region: ENV['AWS_S3_EXPORT_REGION'] || ENV['AWS_S3_REGION'],
          access_key_id: ENV['AWS_EXPORT_ACCESS_KEY_ID'] || ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_EXPORT_SECRET_ACCESS_KEY'] || ENV['AWS_SECRET_ACCESS_KEY']
        }
      end
    end
  end
end

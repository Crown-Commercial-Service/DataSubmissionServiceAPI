require 'aws-sdk-s3'

module Export
  class S3Upload
    # This should be set to true in TEST mode to enable AWS SDK response stubbing
    cattr_accessor :test_mode

    attr_reader :files, :logger

    def initialize(files, logger = Rails.logger)
      @files = Array(files)
      @logger = logger
    end

    def perform
      files.each { |file| upload(file) }
    end

    def client
      @client ||= Aws::S3::Client.new(client_config)
    end

    private

    def upload(file)
      filename = File.basename(file.path)
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
        { region: ENV['AWS_S3_REGION'] }
      end
    end
  end
end

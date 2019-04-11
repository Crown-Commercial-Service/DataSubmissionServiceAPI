class VcapParser
  def self.load_service_environment_variables!
    return if ENV['VCAP_SERVICES'].blank?

    vcap_json = JSON.parse(ENV['VCAP_SERVICES'])
    vcap_json.fetch('user-provided', []).each do |service|
      service['credentials'].each_pair do |key, value|
        ENV[key] = value
      end
    end

    load_ingest_bucket_config(
      vcap_json.fetch('aws-s3-bucket', [])
               .find { |aws_config| aws_config.fetch('name').match?(/^ingest-bucket-/) }
    )
  end

  def self.load_ingest_bucket_config(ingest_bucket_config)
    return unless ingest_bucket_config

    ENV['AWS_ACCESS_KEY_ID'] = ingest_bucket_config.fetch('credentials').fetch('aws_access_key_id')
    ENV['AWS_SECRET_ACCESS_KEY'] = ingest_bucket_config.fetch('credentials').fetch('aws_secret_access_key')
    ENV['AWS_S3_REGION'] = ENV['AWS_REGION'] = ingest_bucket_config.fetch('credentials').fetch('aws_region')
    ENV['AWS_S3_BUCKET'] = ingest_bucket_config.fetch('credentials').fetch('bucket_name')
  end
end

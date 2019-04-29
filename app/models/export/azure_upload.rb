require 'azure/storage/blob'

module Export
  class AzureUpload
    attr_reader :file_map, :logger

    def initialize(file_map, logger = Rails.logger)
      @file_map = file_map
      @logger = logger
    end

    def perform
      file_map.each_pair { |filename, file| upload(filename, file) }
    end

    def client
      @client ||= Azure::Storage::Blob::BlobService.create(client_config)
    end

    private

    def upload(filename, file)
      logger.info "Uploading #{filename} to #{container_name} on Azure"
      client.create_block_blob(container_name, filename, file.read)
      file.rewind
    end

    def container_name
      ENV['AZURE_CONTAINER_NAME']
    end

    def client_config
      {
        storage_account_name: ENV['AZURE_ACCOUNT_NAME'],
        storage_access_key: ENV['AZURE_ACCOUNT_KEY']
      }
    end
  end
end

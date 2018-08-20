# frozen_string_literal: true

module StorageHelpers
  # Returns the key for a stubbed ActiveStorage::Blob as it would be stored
  # by the Disk-based storage service.
  def stubbed_blob_key
    @stubbed_blob_key ||= begin
      FileUtils.mkdir_p Rails.root.join('tmp', 'storage', 'te', 'st')
      FileUtils.touch Rails.root.join('tmp', 'storage', 'te', 'st', 'test-file')
      'test-file'
    end
  end
end

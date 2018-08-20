# frozen_string_literal: true

class DeserializableSubmissionFileBlob < JSONAPI::Deserializable::Resource
  attributes :key, :filename, :content_type, :byte_size, :checksum
end

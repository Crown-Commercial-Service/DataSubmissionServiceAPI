class SerializableUrnList < JSONAPI::Serializable::Resource
  type 'urn_list'

  attributes :file_key

  attribute :filename do
    @object.excel_file.filename.to_s
  end

  attribute :byte_size do
    @object.excel_file.byte_size
  end
end

require 'aws-sdk-s3'

module IngestHelpers
  def fake_download(filename)
    fixture_path = Rails.root.join('spec', 'fixtures', filename)
    extension = filename.split('.').last

    temp_file = Tempfile.new(['fixture', ".#{extension}"])

    FileUtils.copy(fixture_path, temp_file)

    double(
      'fake_download',
      temp_file: temp_file,
    )
  end

  def stub_s3_get_object(filename)
    fixture_path = Rails.root.join('spec', 'fixtures', filename)
    body = File.binread(fixture_path)

    Aws.config[:s3] = {
      stub_responses: {
        get_object: { body: body }
      }
    }
  end

  def stub_s3_get_object_with_exception(exception)
    Aws.config[:s3] = {
      stub_responses: {
        get_object: exception
      }
    }
  end
end

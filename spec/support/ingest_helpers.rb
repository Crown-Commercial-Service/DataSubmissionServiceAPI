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
end

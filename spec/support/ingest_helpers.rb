module IngestHelpers
  def fake_download(filename)
    fixture_path = Rails.root.join('spec', 'fixtures', filename)
    temp_file = "/tmp/fixture_#{filename}"

    FileUtils.copy(fixture_path, temp_file)

    double(
      'fake_download',
      temp_file: temp_file,
      successful?: true,
      downloaded?: true
    )
  end
end

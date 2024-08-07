RSpec.configure do |config|
  config.before(:each) do
    ActiveStorage::Current.url_options = { host: 'http://s3.example.com' }
  end

  config.after(:each) do
    FileUtils.rm_rf Rails.root.join('tmp', 'storage')
  end
end

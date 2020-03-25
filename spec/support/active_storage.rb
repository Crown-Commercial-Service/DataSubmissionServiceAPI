RSpec.configure do |config|
  config.before(:each) do
    Rails.application.routes.default_url_options[:host] = 's3.example.com'
  end

  config.after(:each) do
    FileUtils.rm_rf Rails.root.join('tmp', 'storage')
  end
end

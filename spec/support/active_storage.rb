RSpec.configure do |config|
  config.after(:each) do
    FileUtils.rm_rf Rails.root.join('tmp', 'storage')
  end
end

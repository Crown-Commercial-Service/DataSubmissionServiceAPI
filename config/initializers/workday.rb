Workday.configure do |config|
  config.api_username = ENV['WORKDAY_API_USERNAME']
  config.api_password = ENV['WORKDAY_API_PASSWORD']
end

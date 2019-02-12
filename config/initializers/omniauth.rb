require 'omniauth/strategies/developer_admin'

Rails.application.config.middleware.use OmniAuth::Builder do
  if OmniAuth::Strategies::DeveloperAdmin.applies?
    provider :developer_admin
  else
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], prompt: 'consent'
  end
end

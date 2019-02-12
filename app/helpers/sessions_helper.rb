module SessionsHelper
  def auth_provider_path
    strategy = OmniAuth::Strategies::DeveloperAdmin.applies? ? 'developer_admin' : 'google_oauth2'
    "/auth/#{strategy}"
  end
end

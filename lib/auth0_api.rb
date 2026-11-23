require 'auth0'
require 'auth0/version'

class Auth0Api
  def client
    @client ||= Auth0::Client.new(
      client_id: ENV['AUTH0_CLIENT_ID'],
      client_secret: ENV['AUTH0_CLIENT_SECRET'],
      domain: ENV['AUTH0_DOMAIN']
    )
  end
end

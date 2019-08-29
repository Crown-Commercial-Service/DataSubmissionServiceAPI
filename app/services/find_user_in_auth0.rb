require './lib/auth0_api'

class FindUserInAuth0
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    auth0_response = auth0_client.get_users(q: "email:#{user.email}")
    auth0_client.headers = auth0_client.headers.except(:params)
    return nil if auth0_response.empty?

    auth0_response[0].dig('user_id')
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end
end

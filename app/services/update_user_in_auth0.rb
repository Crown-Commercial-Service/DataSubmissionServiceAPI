require './lib/auth0_api'

class UpdateUserInAuth0
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    auth0_client.update_user(user.auth_id, name: user.name)
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end
end

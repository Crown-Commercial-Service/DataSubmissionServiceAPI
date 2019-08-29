class DeleteUserInAuth0
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    return unless user.active?

    auth0_client.delete_user(user.auth_id)
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end
end

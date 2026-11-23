class UpdateUserEmailInAuth0
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    auth0_client.users.update(id: user.auth_id, email: user.email, verify_email: false, email_verified: true)
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end
end

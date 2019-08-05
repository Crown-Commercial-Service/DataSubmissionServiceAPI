require './lib/auth0_api'

class CreateUserInAuth0
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    return if updated_existing_user!

    auth0_response = auth0_client.create_user(
      user.name,
      email: user.email,
      email_verified: true,
      password: CreateUserInAuth0.temporary_password,
      connection: 'Username-Password-Authentication',
    )
    user.update(auth_id: auth0_response.fetch('user_id'))
  end

  def self.temporary_password
    "#{SecureRandom.urlsafe_base64}aA1!"
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end

  def updated_existing_user!
    return false if existing_user_id.blank?

    user.update(auth_id: existing_user_id)
    true
  end

  def existing_user_id
    @existing_user_id ||= begin
      auth0_response = auth0_client.get_users(q: "email:#{user.email}")
      auth0_client.headers = auth0_client.headers.except(:params)
      return nil if auth0_response.empty?

      auth0_response[0].dig('user_id')
    end
  end
end

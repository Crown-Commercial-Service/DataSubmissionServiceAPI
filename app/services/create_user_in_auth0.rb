require './lib/auth0_api'

class CreateUserInAuth0
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    auth0_response = auth0_client.create_user(
      'Username-Password-Authentication',
      name: user.name,
      email: user.email,
      email_verified: true,
      password: CreateUserInAuth0.temporary_password
    )
    user.update(auth_id: auth0_response.fetch('user_id'))
  rescue Auth0::Unsupported => e
    error_hash = JSON.parse(e.to_s)
    if error_hash['statusCode'].eql?(409) &&
       error_hash['message'].eql?('The user already exists.')
      updated_existing_user!
    else
      raise e
    end
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
    @existing_user_id ||= FindUserInAuth0.new(user: user).call
  end
end

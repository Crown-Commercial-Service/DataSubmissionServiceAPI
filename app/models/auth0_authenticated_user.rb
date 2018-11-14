# Used to create a new User record, setting up the required authorisation in
# Auth0, the current authentication service.
#
# See docs/onboarding-suppliers.md for example usage
class Auth0AuthenticatedUser
  AUTH0_DATABASE_BASED_CONNECTION_NAME = 'Username-Password-Authentication'.freeze

  attr_reader :auth0_client, :full_name, :email, :supplier_name, :supplier_id

  def initialize(auth0_client, full_name, email, supplier_name, supplier_id)
    @auth0_client = auth0_client
    @full_name = full_name
    @email = email
    @supplier_name = supplier_name
    @supplier_id = supplier_id
  end

  def create!
    auth0_response = auth0_client.create_user(full_name, auth0_create_options)
    User.create!(email: email, auth_id: auth0_response.fetch('user_id'))
  end

  private

  def auth0_create_options
    {
      email: email,
      email_verified: true,
      password: random_password,
      connection: AUTH0_DATABASE_BASED_CONNECTION_NAME,
      app_metadata: {
        supplier: supplier_name,
        supplier_id: supplier_id
      }
    }
  end

  def random_password
    SecureRandom.urlsafe_base64
  end
end

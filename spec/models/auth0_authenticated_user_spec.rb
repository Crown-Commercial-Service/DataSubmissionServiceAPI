require 'rails_helper'

RSpec.describe Auth0AuthenticatedUser do
  let(:auth0_client) { instance_double('Auth0 client') }
  let(:auth0_create_user_response) do
    {
      'email' => email,
      'email_verified' => true,
      'name' => user_name,
      'updated_at' => '2018-09-25T12:19:46.006Z',
      'picture' => 'https://s.gravatar.com/avatar/1234.png',
      'user_id' => 'auth0|12345',
      'nickname' => user_name,
      'identities' => [
        {
          'connection' => 'Username-Password-Authentication',
          'user_id' => '12345',
          'provider' => 'auth0',
          'isSocial' => false
        }
      ],
      'created_at' => '2018-09-25T12:19:46.006Z',
      'app_metadata' => { 'supplier' => supplier_name, 'supplier_id' => supplier_id }
    }
  end
  let(:user_name) { 'Test User' }
  let(:email) { 'test@user.com' }
  let(:supplier_name) { 'DXW' }
  let(:supplier_id) { '123456' }
  let(:auth0_authenticated_user) do
    Auth0AuthenticatedUser.new(auth0_client, user_name, email, supplier_name, supplier_id)
  end

  describe '#create' do
    it 'creates the user on Auth0 and creates a corresponding database record matching the auth0 user id' do
      expect(auth0_client).to receive(:create_user).with(
        user_name,
        a_hash_including(
          email: email,
          email_verified: true,
          password: kind_of(String),
          connection: Auth0AuthenticatedUser::AUTH0_DATABASE_BASED_CONNECTION_NAME,
          app_metadata: {
            supplier: supplier_name,
            supplier_id: supplier_id
          }
        )
      ).and_return(auth0_create_user_response)

      user = auth0_authenticated_user.create!

      expect(user).to be_persisted
      expect(user.email).to eq 'test@user.com'
      expect(user.auth_id).to eq 'auth0|12345'
    end
  end
end

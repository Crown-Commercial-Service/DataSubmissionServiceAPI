require 'rails_helper'

RSpec.describe CreateUserInAuth0 do
  describe '#call' do
    let(:user) { create(:user, :inactive) }

    subject { described_class.new(user: user).call }

    before(:each) do
      stub_auth0_token_request
    end

    it 'creates the user in Auth0 and updates the local user auth_id' do
      stub_auth0_get_users_request(email: user.email)
      auth0_create_call = stub_auth0_create_user_request(user.email)

      subject

      expect(auth0_create_call).to have_been_requested
      expect(user.auth_id).to eq("auth0|#{user.email}")
    end

    context 'when the user already has an auth_id' do
      let(:user) { create(:user, auth_id: 'auth|old') }

      context 'when the ID is different from Auth0' do
        it 'updates the user with the version found in auth0' do
          stub_auth0_get_users_request(
            email: user.email,
            auth_id: 'auth|new',
            user_already_exists: true
          )

          subject

          expect(user.auth_id).to eq('auth|new')
        end
      end

      context 'when the auth_id is the same as Auth0 for that email' do
        let(:user) { create(:user, auth_id: 'auth|old') }

        it 'does not perform an update' do
          stub_auth0_get_users_request(
            email: user.email,
            auth_id: 'auth|old',
            user_already_exists: true
          )

          subject

          expect(user.changed?).to eq(false)
          expect(user.auth_id).to eq('auth|old')
        end

        it 'does not send a create request to Auth0' do
          stub_auth0_get_users_request(
            email: user.email,
            auth_id: 'auth|old',
            user_already_exists: true
          )

          auth0_create_call = stub_auth0_create_user_request(user.email)

          subject

          expect(auth0_create_call).not_to have_been_requested
        end
      end
    end

    context 'with a user whose email address already exists in Auth0' do
      it 'updates auth_id from the current Auth0 user' do
        auth0_check_user_exists = stub_auth0_get_users_request(
          email: user.email,
          auth_id: 'auth0|456',
          user_already_exists: true
        )
        auth0_create_call = stub_auth0_create_user_request(user.email)

        subject

        expect(auth0_check_user_exists).to have_been_requested
        expect(auth0_create_call).not_to have_been_requested
        expect(user.auth_id).to eq('auth0|456')
      end
    end
  end

  describe '#temporary_password' do
    it 'conforms to the Auth0 criteria' do
      password = described_class.temporary_password

      expect(password).to match(/[a-z]/)
      expect(password).to match(/[A-Z]/)
      expect(password).to match(/[0-9]/)
      expect(password).to match(/[!@#$%^&*]/)
    end
  end
end

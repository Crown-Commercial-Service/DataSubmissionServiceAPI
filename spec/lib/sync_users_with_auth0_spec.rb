require 'rails_helper'
require 'sync_users_with_auth0'

RSpec.describe SyncUsersWithAuth0 do
  before(:each) do
    stub_auth0_token_request
  end

  describe '.run!' do
    it 'updates local user record auth_id fields with the auth0 value' do
      known_out_of_sync_user_email = 'email@example.com'
      user = create(:user, email: known_out_of_sync_user_email, auth_id: 'auth0|an-old-value')

      stub_auth0_get_users_request(
        email: known_out_of_sync_user_email,
        auth_id: 'auth0|the-new-value',
        user_already_exists: true
      )

      described_class.run!

      expect(user.reload.auth_id).to eq('auth0|the-new-value')
    end

    context 'when the auth_id matches' do
      it 'does not change the user record' do
        email = 'email@example.com'
        user = create(:user, email: email, auth_id: 'auth0|an-old-value')

        stub_auth0_get_users_request(
          email: email,
          auth_id: 'auth0|the-old-value',
          user_already_exists: true
        )

        described_class.run!

        expect(user.changed?).to eq(false)
        expect(user.reload.auth_id).to eq('auth0|the-old-value')
      end
    end

    context 'when the user email cannot be found in auth0' do
      it 'logs a warning to the developer' do
        user_that_only_exists_in_the_api = create(:user)

        stub_auth0_get_users_request(
          email: user_that_only_exists_in_the_api.email,
          auth_id: user_that_only_exists_in_the_api.auth_id,
          user_already_exists: false
        )

        expect(Rails.logger).to receive(:info)
          .with("Email: #{user_that_only_exists_in_the_api.email} could not be found in Auth0")

        described_class.run!

        expect(user.changed?).to eq(false)
      end
    end

    context 'when called with the dry-run true' do
      it 'does not perform the update, but logs that it would have tried' do
      end
    end
  end
end

require 'rails_helper'
require 'auth0'

RSpec.describe FindUserInAuth0 do
  describe '#call' do
    let(:user) { create(:user, :inactive) }

    subject { described_class.new(user: user).call }

    before(:each) do
      stub_auth0_token_request
    end

    it 'returns the auth_id for an existing user' do
      stub_auth0_get_users_request(
        email: user.email,
        auth_id: 'auth|old',
        user_already_exists: true
      )

      result = subject

      expect(result).to eq('auth|old')
    end

    context 'when that email does not exist' do
      it 'returns nil' do
        stub_auth0_get_users_request(
          email: user.email,
          user_already_exists: false
        )

        result = subject

        expect(result).to eq(nil)
      end
    end
  end
end

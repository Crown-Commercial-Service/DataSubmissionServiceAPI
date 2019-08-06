require 'rails_helper'

RSpec.describe DeleteUserInAuth0 do
  describe '#call' do
    let(:user) { create(:user) }

    subject { described_class.new(user: user).call }

    before(:each) do
      stub_auth0_token_request
    end

    it 'deletes the user in Auth0' do
      auth0_delete_call = stub_auth0_delete_user_request(user)

      subject

      expect(auth0_delete_call).to have_been_requested
    end

    context 'an inactive user' do
      let(:user) { create(:user, :inactive) }

      it 'does not do anything' do
        auth0_delete_call = stub_auth0_delete_user_request(user)

        subject

        expect(auth0_delete_call).not_to have_been_requested
      end
    end
  end
end

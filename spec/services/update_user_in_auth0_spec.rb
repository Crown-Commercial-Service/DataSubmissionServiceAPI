require 'rails_helper'

RSpec.describe UpdateUserInAuth0 do
  describe '#call' do
    let(:user) { create(:user) }

    subject { described_class.new(user: user).call }

    before(:each) do
      stub_auth0_token_request
    end

    it 'updates the user in Auth0' do
      auth0_update_call = stub_auth0_update_user_request(user)

      subject

      expect(auth0_update_call).to have_been_requested
    end
  end
end

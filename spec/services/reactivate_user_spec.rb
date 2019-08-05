require 'rails_helper'

RSpec.describe ReactivateUser do
  let(:user) { create(:user, auth_id: nil) }

  before(:each) do
    stub_auth0_token_request
    stub_auth0_get_users_request(email: user.email)
  end

  describe '#call' do
    it 'returns a successful result' do
      stub_auth0_create_user_request(user.email)

      result = described_class.new(user: user).call

      expect(result.success?).to eq(true)
      expect(result.failure?).to eq(false)
    end

    context 'when Auth0 errors' do
      before(:each) do
        stub_auth0_create_user_request_failure(user.email)
      end

      it 'returns a failed result' do
        result = described_class.new(user: user).call
        expect(result.failure?).to eq(true)
      end

      it 'does not update the user' do
        described_class.new(user: user).call
        expect(user.changed?).to eq(false)
      end

      it 'logs a failure message' do
        expect(Rails.logger).to receive(:error)
          .with("Error adding user #{user.email} to Auth0 during ReactivateUser")
        described_class.new(user: user).call
      end
    end
  end
end

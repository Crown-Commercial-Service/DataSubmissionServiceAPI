require 'rails_helper'

RSpec.describe UpdateUser do
  let(:user) { FactoryBot.create(:user) }
  before(:each) do
    stub_auth0_token_request
  end

  describe '#call' do
    it 'returns a successful result' do
      stub_auth0_update_user_request(user)

      result = described_class.new(user, 'Test').call

      expect(result.success?).to eq(true)
      expect(result.failure?).to eq(false)
    end

    context 'when Auth0 errors' do
      before(:each) do
        stub_auth0_update_user_request_failure(user)
      end

      it 'returns a failed result' do
        result = described_class.new(user, 'Test').call
        expect(result.failure?).to eq(true)
      end

      it 'does not update the user' do
        described_class.new(user, 'Test').call
        expect(user.changed?).to eq(false)
      end

      it 'logs a failure message' do
        expect(Rails.logger).to receive(:error)
          .with("Error updating user name for #{user.email} in Auth0 during UpdateUser")
        described_class.new(user, 'Test').call
      end
    end
  end
end

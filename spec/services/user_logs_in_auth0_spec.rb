require 'rails_helper'

RSpec.describe UserLogsInAuth0 do
  describe '#call' do
    let(:user) { create(:user) }

    subject { described_class.new(user: user).call }

    before(:each) do
      stub_auth0_token_request
    end

    it 'fetches logs from Auth0' do
      auth0_logs_call = stub_request(:get, /api\/v2\/logs/)
                        .to_return(status: 200, body: { logs: [] }.to_json, headers: { 'Content-Type' => 'application/json' })

      subject

      expect(auth0_logs_call).to have_been_requested
    end
  end
end

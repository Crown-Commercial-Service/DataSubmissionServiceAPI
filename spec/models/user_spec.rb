require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:memberships) }

  describe '#create_with_auth0' do
    let(:user) { FactoryBot.create(:user) }
    let!(:auth0_create_call) { stub_auth0_create_user_request }

    before { stub_auth0_token_request }

    it 'submits to Auth0 and updates auth_id' do
      user.create_with_auth0

      expect(auth0_create_call).to have_been_requested
      expect(user.auth_id).to eq('auth0|TEST')
    end
  end

  describe '#delete_on_auth0' do
    let(:user) { FactoryBot.create(:user) }
    let!(:auth0_delete_call) { stub_auth0_delete_user_request(user) }

    before { stub_auth0_token_request }

    it 'deletes user on Auth0 and nils auth_id' do
      user.delete_on_auth0

      expect(auth0_delete_call).to have_been_requested
      expect(user.auth_id).to eq(nil)
    end
  end
end

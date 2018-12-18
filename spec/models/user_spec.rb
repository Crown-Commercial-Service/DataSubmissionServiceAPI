require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:memberships) }

  describe '#create_with_auth0' do
    let(:user) { FactoryBot.create(:user) }
    let!(:auth0_create_call) { stub_auth0_create_user_request(user.email) }

    before { stub_auth0_token_request }

    it 'submits to Auth0 and updates auth_id' do
      user.create_with_auth0

      expect(auth0_create_call).to have_been_requested
      expect(user.auth_id).to eq("auth0|#{user.email}")
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

  describe '.search' do
    let!(:bob) { FactoryBot.create(:user, name: 'Bob Booker', email: 'bob@sheffield.com') }
    let!(:bobby) { FactoryBot.create(:user, name: 'Bobby Brown', email: 'bobby_b_66@hotmail.com') }

    before do
      bob.suppliers << FactoryBot.create(:supplier, name: 'Brentford FC')
    end

    it 'returns users with names matching the supplied search term' do
      expect(User.search('bob')).to match_array([bob, bobby])
      expect(User.search('Frank')).to match_array([])
    end

    it 'returns users with email addresses matching the supplied search term' do
      expect(User.search('sheffield.com')).to match_array([bob])
      expect(User.search('bobby_b')).to match_array([bobby])
      expect(User.search('foobar')).to match_array([])
    end

    it 'returns users linked to a supplier matching the supplied search term' do
      expect(User.search('Brentford')).to match_array([bob])
    end

    context 'when user is associated with multiple suppliers' do
      before do
        bob.suppliers << FactoryBot.create(:supplier, name: 'Sheffield United')
      end

      it 'doesn’t return multiple results for the matching user' do
        expect(User.search('booker')).to match_array([bob])
      end
    end
  end
end

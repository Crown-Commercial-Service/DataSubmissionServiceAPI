require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:memberships) }

  describe 'validations' do
    it 'fails for duplicate email address, with differing case' do
      FactoryBot.create(:user, email: 'Jo.Soap@example.com')
      new_user = FactoryBot.build(:user, email: 'jo.soap@example.com')

      expect(new_user).not_to be_valid
      expect(new_user.errors[:email]).to be_present
    end
  end

  describe '#name=' do
    it 'strips whitespace when set' do
      user = FactoryBot.create(:user, name: '   Jo   Soap ')

      expect(user.name).to eql 'Jo Soap'
    end
  end

  describe '#email=' do
    it 'strips whitespace when set' do
      user = FactoryBot.create(:user, email: '  jo.soap@example.com     ')

      expect(user.email).to eql 'jo.soap@example.com'
    end
  end

  describe '#create_with_auth0' do
    let(:user) { FactoryBot.create(:user, :inactive) }
    let!(:auth0_check_user_exists) { stub_auth0_get_users_request(email: user.email) }
    let!(:auth0_create_call) { stub_auth0_create_user_request(user.email) }

    before(:each) do
      stub_auth0_token_request
    end

    it 'submits to Auth0 and updates auth_id' do
      user.create_with_auth0

      expect(auth0_create_call).to have_been_requested
      expect(user.auth_id).to eq("auth0|#{user.email}")
    end

    context 'with a user whose email address already exists in Auth0' do
      let!(:auth0_check_user_exists) do
        stub_auth0_get_users_request(
          email: user.email,
          auth_id: 'auth0|456',
          user_already_exists: true
        )
      end

      it 'updates auth_id from the current Auth0 user' do
        user.create_with_auth0

        expect(auth0_check_user_exists).to have_been_requested
        expect(auth0_create_call).not_to have_been_requested
        expect(user.auth_id).to eq('auth0|456')
      end
    end
  end

  describe '#temporary_password' do
    it 'conforms to the Auth0 criteria' do
      password = User.new.temporary_password

      expect(password).to match(/[a-z]/)
      expect(password).to match(/[A-Z]/)
      expect(password).to match(/[0-9]/)
      expect(password).to match(/[!@#$%^&*]/)
    end
  end

  describe '#active?' do
    subject { user.active? }

    context 'an active user' do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to be_truthy }
    end

    context 'an inactive user' do
      let(:user) { FactoryBot.create(:user, :inactive) }

      it { is_expected.to be_falsy }
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

  describe '#deactivate' do
    let!(:auth0_delete_call) { stub_auth0_delete_user_request(user) }

    before { stub_auth0_token_request }

    context 'an active user' do
      let(:user) { FactoryBot.create(:user) }

      it 'deletes user on Auth0 and nils auth_id' do
        user.deactivate

        expect(auth0_delete_call).to have_been_requested
        expect(user.auth_id).to eq(nil)
      end
    end

    context 'an inactive user' do
      let(:user) { FactoryBot.create(:user, :inactive) }

      it 'does not do anything' do
        user.deactivate

        expect(auth0_delete_call).not_to have_been_requested
        expect(user.auth_id).to eq(nil)
      end
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

  context 'scopes' do
    let!(:active_user) { FactoryBot.create(:user) }
    let!(:inactive_user) { FactoryBot.create(:user, :inactive) }

    describe '.active' do
      it 'returns only active users' do
        expect(User.active.count).to eq(1)
      end
    end

    describe '.inactive' do
      it 'returns only inactive users' do
        expect(User.inactive.count).to eq(1)
      end
    end
  end
end

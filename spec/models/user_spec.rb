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

    it 'fails for invalid address formats' do
      user = FactoryBot.create(:user)
      user.email = 'somebody@example'

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
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

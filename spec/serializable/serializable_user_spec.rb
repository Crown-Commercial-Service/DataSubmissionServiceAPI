require 'rails_helper'

RSpec.describe SerializableUser do
  context 'given a user' do
    let(:user) { FactoryBot.create(:user) }
    let(:serialized_user) { SerializableUser.new(object: user) }

    it 'exposes a multiple_suppliers boolean' do
      expect(serialized_user.as_jsonapi[:attributes][:multiple_suppliers?]).to eq(false)
    end
  end
end

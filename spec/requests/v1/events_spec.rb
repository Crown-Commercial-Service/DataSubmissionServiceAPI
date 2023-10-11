require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  describe 'POST /events/user_signed_in' do
    it 'stores the UserSignedIn event to the audit log' do
      event_store = RailsEventStore::Client.new

      post "/v1/events/user_signed_in?user_id=#{JWT.encode(user.auth_id, 'test')}"

      expect(response).to have_http_status(:created)
      expect(event_store).to have_published(an_event(UserSignedIn).with_data(user_id: user.auth_id))
    end
  end

  describe 'POST /events/user_signed_out' do
    it 'stores the UserSignedOut event to the audit log' do
      event_store = RailsEventStore::Client.new

      post "/v1/events/user_signed_out?user_id=#{JWT.encode(user.auth_id, 'test')}"

      expect(response).to have_http_status(:created)
      expect(event_store).to have_published(an_event(UserSignedOut).with_data(user_id: user.auth_id))
    end
  end
end

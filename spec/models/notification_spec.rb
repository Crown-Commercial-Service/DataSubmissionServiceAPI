require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'validations' do
    subject { create(:notification, published: true, notification_message: 'test') }
    it { is_expected.to validate_presence_of(:notification_message) }
  end

  describe '#unpublish!' do
    let!(:notification) do
      create :notification, published: true, notification_message: 'It may be too late for another coffee'
    end
    subject! { notification.unpublish! }
    it 'sets published value to false and the unpublished_at timestamp' do
      notification.reload
      expect(notification.published).to be_falsey
      expect(notification.unpublished_at).not_to be_nil
    end
  end

  describe 'publishing logic' do
    it 'unpublishes other notifications when a new one is published' do
      first_notification = create(:notification, published: true)
      create(:notification, published: true, notification_message: 'Beware the dog')

      first_notification.reload
      expect(first_notification.published).to be_falsey
    end
  end
end

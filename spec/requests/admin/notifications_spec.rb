require 'rails_helper'

RSpec.describe 'Admin Notifications', type: :request do
  include SingleSignOnHelpers

  before do
    stub_govuk_bank_holidays_request
    mock_sso_with(email: 'admin@example.com')
    get '/auth/google_oauth2/callback'
  end

  describe '#preview' do
    it 'renders the Markdown content as HTML' do
      markdown_content = '**Bold Text**'
      expected_html = '<p class="govuk-body"><strong>Bold Text</strong></p>'

      post admin_notifications_preview_path, params: { summary: 'summary', message: markdown_content }

      expect(response).to be_successful
      expect(response.header['Content-Type']).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq(expected_html)
    end
  end

  describe '#unpublish' do
    let!(:notification) { create(:notification, published: true) }

    context 'when unpublishing is successful' do
      it 'unpublishes the notification and redirects with a success message' do
        post unpublish_admin_notification_path(notification.id)

        notification.reload
        expect(notification.published).to be_falsey
        expect(response).to redirect_to admin_notifications_path
        expect(flash[:notice]).to eq('Notification was successfully unpublished.')
      end
    end

    context 'when unpublishing fails' do
      before do
        allow(Notification).to receive(:find).and_return(notification)
        allow(notification).to receive(:unpublish!).and_return(false)
        notification.errors.add(:base, 'Unable to unpublishdue to some error')
      end

      it 'does not unpublish the notification and redirects with an error message' do
        post unpublish_admin_notification_path(notification.id)

        expect(response).to redirect_to admin_notifications_path
        expect(flash[:alert]).to eq('Unable to unpublish notification.')
      end
    end
  end
end

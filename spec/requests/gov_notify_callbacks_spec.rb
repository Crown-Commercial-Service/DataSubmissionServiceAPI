require 'rails_helper'

RSpec.describe 'GovNotifyCallbacks', type: :request do
  let(:callback_token) { 'test-callback-token' }

  let(:batch) do
    NotificationBatch.create!(
      notification_type: 'due',
      template_id: 'template-id',
      status: 'submitted',
      started_at: Time.current
    )
  end

  let!(:delivery) do
    batch.notification_deliveries.create!(
      email: 'test@example.com',
      supplier_name: 'Test Supplier',
      reference: 'delivery-reference',
      notify_id: 'notify-id',
      status: 'created',
      sent_at: 1.minute.ago
    )
  end

  let(:headers) do
    {
      'Authorization' => "Bearer #{callback_token}"
      # 'Content-Type' => 'application/json'
    }
  end

  let(:callback_body) do
    {
      id: 'notify-id',
      reference: 'delivery-reference',
      status: 'delivered',
      sent_at: '2026-09-23T10:00:00Z',
      completed_at: '2026-09-23T10:01:00Z'
    }
  end

  around do |example|
    ClimateControl.modify(
      GOV_NOTIFY_CALLBACK_TOKEN: callback_token
    ) do
      example.run
    end
  end

  def send_callback(body: callback_body, request_headers: headers)
    post(
      '/gov_notify/callbacks/delivery',
      params: body,
      headers: request_headers,
      as: :json
    )
  end

  it 'accepts an authenticated callback' do
    send_callback

    expect(response).to have_http_status(:no_content)
  end

  it 'updates the delivery status' do
    send_callback

    expect(delivery.reload.status).to eq('delivered')
  end

  it 'records the completion time' do
    send_callback

    expect(delivery.reload.completed_at).to eq(Time.zone.parse('2026-09-23T10:01:00Z'))
  end

  %w[
    delivered
    permanent-failure
    temporary-failure
    technical-failure
  ].each do |status|
    it "records a #{status} status" do
      send_callback(
        body: callback_body.merge(status: status)
      )

      expect(delivery.reload.status).to eq(status)
    end
  end

  context 'when the notify id is not yet stored' do
    before do
      delivery.update!(notify_id: nil)
    end

    it 'finds the delivery using the reference' do
      expect(delivery.reload.notify_id).to be_nil
      expect(delivery.reference).to eq('delivery-reference')

      expect(
        NotificationDelivery.find_by(reference: 'delivery-reference')
      ).to eq(delivery)

      send_callback

      expect(response).to have_http_status(:no_content)
      expect(delivery.reload.status).to eq('delivered')
    end

    it 'stores the notify id from the callback' do
      send_callback

      expect(delivery.reload.notify_id).to eq('notify-id')
    end
  end

  context 'when the callback token is incorrect' do
    it 'returns unauthorized' do
      send_callback(
        request_headers: headers.merge(
          'Authorization' => 'Bearer wrong-token'
        )
      )

      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the delivery' do
      expect do
        send_callback(
          request_headers: headers.merge(
            'Authorization' => 'Bearer wrong-token'
          )
        )
      end.not_to change { delivery.reload.status }
    end
  end

  context 'when the authorization header is missing' do
    it 'returns unauthorized' do
      send_callback(
        request_headers: {
          'Content-Type' => 'application/json'
        }
      )

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when no delivery can be found' do
    it 'returns not found' do
      send_callback(
        body: callback_body.merge(
          id: 'unknown-id',
          reference: 'unknown-reference'
        )
      )

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when Notify sends the callback more than once' do
    it 'is idempotent' do
      send_callback
      send_callback

      expect(response).to have_http_status(:no_content)
      expect(delivery.reload.status).to eq('delivered')
    end
  end
end

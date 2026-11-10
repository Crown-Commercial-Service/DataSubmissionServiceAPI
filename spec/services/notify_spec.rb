require 'rails_helper'

RSpec.describe Notify do
  subject(:notify) { described_class.new }

  let(:client) { instance_double(Notifications::Client) }
  let(:response) { instance_double('NotificationResponse', id: 'notify-id') }

  before do
    allow(Notifications::Client)
      .to receive(:new)
      .with(ENV['GOV_NOTIFY_API_KEY'])
      .and_return(client)
  end

  describe '#send_email' do
    it 'sends an email using the GOV.UK Notify API' do
      allow(client).to receive(:send_email).and_return(response)

      notify.send_email(
        template_id: 'template-id',
        email: 'test@example.com',
        vars: { name: 'John Doe' },
        reference: 'reference'
      )

      expect(client).to have_received(:send_email).with(
        email_address: 'test@example.com',
        template_id: 'template-id',
        personalisation: { name: 'John Doe' },
        reference: 'reference'
      )
    end

    it 'returns the response from the Notify API' do
      allow(client).to receive(:send_email).and_return(response)

      result = notify.send_email(
        template_id: 'template-id',
        email: 'test@example.com',
        vars: { name: 'John Doe' },
        reference: 'reference'
      )

      expect(result).to eq(response)
    end
  end
end

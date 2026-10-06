require 'rails_helper'

RSpec.describe SendConfirmEmailVerificationJob do
  subject(:perform_job) do
    described_class.perform_now(
      new_email: 'new@example.com',
      person_name: 'Alice Example',
    )
  end

  let(:notify) { instance_double(Notify) }

  before do
    allow(Notify).to receive(:new).and_return(notify)
    allow(notify).to receive(:send_email)
  end

  it 'sends the email verification email using the Notify service' do
    perform_job

    expect(notify).to have_received(:send_email).with(
      template_id: described_class::TEMPLATE_ID,
      email: 'new@example.com',
      vars: {
        login_url: ENV['FRONTEND_URL'],
        email_address: 'new@example.com',
        person_name: 'Alice Example'
      }
    )
  end
end

require 'rails_helper'
require 'auth0'

RSpec.describe CreateUserInAuth0 do
  describe '#call' do
    let(:user) { create(:user, :inactive) }

    subject { described_class.new(user: user).call }

    before(:each) do
      stub_auth0_token_request
    end

    it 'creates the user in Auth0 and updates the local user auth_id' do
      allow(FindUserInAuth0).to receive_message_chain(:new, :call).and_return("auth0|#{user.email}")

      auth0_create_call = stub_auth0_create_user_request(user.email)

      subject

      expect(auth0_create_call).to have_been_requested
      expect(user.auth_id).to eq("auth0|#{user.email}")
    end

    context 'when an error is thrown' do
      context 'due to that user already existing' do
        let(:auth0_user_exists_error) do
          params = JSON[{
            'statusCode' => 409,
            'error' => 'Conflict',
            'message' => 'The user already exists.',
            'errorCode' => 'auth0_idp_error'
          }]

          Auth0::Unsupported.new(params)
        end

        it 'fetches that user and updates the local record' do
          allow_any_instance_of(Auth0Api).to receive_message_chain(:client, :create_user)
            .and_raise(auth0_user_exists_error)

          find_user_service_double = double(FindUserInAuth0)
          allow(FindUserInAuth0).to receive(:new)
            .with(user: user)
            .and_return(find_user_service_double)
          expect(find_user_service_double).to receive(:call).and_return('auth|new')

          subject

          expect(user.auth_id).to eql('auth|new')
        end
      end

      context 'for an another unexpected reason' do
        it 'raises the error as an unhandled exception' do
          allow(FindUserInAuth0).to receive_message_chain(:new, :call).and_return('auth|new')

          params = JSON[{
            'statusCode' => 500,
            'error' => 'Foo',
            'message' => 'Bar',
            'errorCode' => 'x_error'
          }]

          unexpected_error = Auth0::Unsupported.new(params)

          allow_any_instance_of(Auth0Api).to receive_message_chain(:client, :create_user)
            .and_raise(unexpected_error)

          expect { subject }.to raise_error(unexpected_error)
        end
      end
    end
  end

  describe '#temporary_password' do
    it 'conforms to the Auth0 criteria' do
      password = described_class.temporary_password

      expect(password).to match(/[a-z]/)
      expect(password).to match(/[A-Z]/)
      expect(password).to match(/[0-9]/)
      expect(password).to match(/[!@#$%^&*]/)
    end
  end
end

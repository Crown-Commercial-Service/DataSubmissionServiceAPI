require 'rails_helper'

RSpec.describe Offboard::DeactivateUsers do
  let!(:supplier) do
    FactoryBot.create(:supplier, salesforce_id: '001b000003FAKEFAKE')
  end

  let!(:user) { FactoryBot.create(:user, name: 'User One', email: 'email_one@ccs.co.uk', suppliers: [supplier]) }

  before do
    stub_auth0_token_request
    stub_auth0_delete_user_request(user)
  end

  it 'raises an error if the expected headers are not present' do
    bad_headers_csv_path = Rails.root.join(
      'spec', 'fixtures', 'suppliers-to-offboard-from-frameworks.csv'
    )

    expect { Offboard::DeactivateUsers.new(bad_headers_csv_path) }.to raise_error(
      ArgumentError, /Missing headers in CSV file: email/
    )
  end

  describe '#run' do
    let(:offboarder) { Offboard::DeactivateUsers.new(csv_path, logger: Logger.new('/dev/null')) }
    let(:csv_path) { Rails.root.join('spec', 'fixtures', 'users-to-offboard.csv') }

    it 'deactivates the user' do
      expect { offboarder.run }.to change { User.where(auth_id: nil).count }.by(1)
    end

    context 'when the CSV contains an email address not in the database' do
      let(:csv_path) { Rails.root.join('spec', 'fixtures', 'user-does-not-exist-to-offboard.csv') }
      it 'raises an error' do
        expect { offboarder.run }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Import::Users do
  it 'raises an error if the expected headers are not present' do
    bad_headers_csv_path = Rails.root.join('spec', 'fixtures', 'users_bad_headers.csv')

    expect { Import::Users.new(bad_headers_csv_path) }.to raise_error(
      ArgumentError, /Missing headers in CSV file: supplier_salesforce_id/
    )
  end

  describe '#run' do
    let(:csv_path) { Rails.root.join('spec', 'fixtures', 'users.csv') }
    let(:jamila_email) { 'jamila@aslan.tr' }
    let(:seema_email) { 'seema@sash123.co.uk' }
    let(:jamila_company_salesforce_id) { '0010N12004XKNGYQA5' }
    let(:seema_company_salesforce_id) { '0010N45004XKN9yQAH' }

    let!(:jamila_company) { FactoryBot.create(:supplier, salesforce_id: jamila_company_salesforce_id) }
    let!(:seema_company) { FactoryBot.create(:supplier, salesforce_id: seema_company_salesforce_id) }

    let(:importer) { Import::Users.new(csv_path, wait_time: 0, logger: Logger.new('/dev/null')) }

    before do
      stub_auth0_create_user_request(jamila_email)
      stub_auth0_create_user_request(seema_email)
      stub_auth0_token_request
    end

    it 'creates users' do
      expect { importer.run }.to change { User.count }.by 2
    end
  end
end

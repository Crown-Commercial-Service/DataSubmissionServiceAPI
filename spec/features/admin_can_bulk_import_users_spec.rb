require 'rails_helper'

RSpec.feature 'Admin can bulk import users' do
  let(:jamila_email) { 'jamila@aslan.tr' }
  let(:seema_email) { 'seema@sash123.co.uk' }
  let(:jamila_company_salesforce_id) { '0010N12004XKNGYQA5' }
  let(:seema_company_salesforce_id) { '0010N45004XKN9yQAH' }

  let!(:jamila_company) { FactoryBot.create(:supplier, salesforce_id: jamila_company_salesforce_id) }
  let!(:seema_company) { FactoryBot.create(:supplier, salesforce_id: seema_company_salesforce_id) }

  before do
    stub_auth0_token_request
    stub_auth0_create_user_request(jamila_email)
    stub_auth0_create_user_request(seema_email)

    sign_in_as_admin
  end

  context 'with a valid CSV' do
    scenario 'creates users that do not exist' do
      visit new_admin_user_bulk_import_path

      expect(page).to have_text 'Bulk import users'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users.csv')

      expect { click_button 'Upload' }.to change { User.count }

      expect(page).to have_text 'Successfully imported users'

      jamila_company_user = jamila_company.users.first
      expect(jamila_company_user.name).to eql 'Jamila Aslan'
      expect(jamila_company_user.email).to eql jamila_email

      seema_company_user = seema_company.users.first
      expect(seema_company_user.name).to eql 'Seema Clarke'
      expect(seema_company_user.email).to eql seema_email
    end
  end

  context 'with a CSV which references a salesforce_id that does not exist' do
    before { seema_company.update(salesforce_id: nil) }

    scenario 'displays an error' do
      visit new_admin_user_bulk_import_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users.csv')

      expect { click_button 'Upload' }.to_not change { User.count }

      expect(page).to have_text 'Could not find a supplier with salesforce_id'
      expect(page).to have_text seema_company_salesforce_id
    end
  end

  context 'with a CSV with missing columns' do
    scenario 'displays an error, showing which columns are missing' do
      visit new_admin_user_bulk_import_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users_bad_headers.csv')
      click_button 'Upload'

      expect(page).to have_text 'Missing headers in CSV file: supplier_salesforce_id'
    end
  end

  context 'with a non-CSV file' do
    scenario 'displays an error' do
      visit new_admin_user_bulk_import_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'not-really-an.xls')
      click_button 'Upload'

      expect(page).to have_text 'Uploaded file is not a CSV file'
    end
  end

  context 'without attaching a file' do
    scenario 'displays an error' do
      visit new_admin_user_bulk_import_path
      click_button 'Upload'

      expect(page).to have_text 'Please choose a file to upload'
    end
  end
end

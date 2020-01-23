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

    stub_auth0_get_users_request(email: jamila_email)
    stub_auth0_get_users_request(email: seema_email)
    stub_auth0_create_user_request(jamila_email)
    stub_auth0_create_user_request(seema_email)

    sign_in_as_admin
  end

  context 'with a valid CSV' do
    before do
      allow_any_instance_of(UploadUserList).to receive(:call).and_return('fake_key')
    end

    scenario 'shows the admin a message that the bulk upload happens asynchronously' do
      visit new_admin_user_bulk_import_path

      expect(page).to have_text 'Bulk import users'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users.csv')

      expect(UserImportJob).to receive(:perform_later).with('fake_key')

      click_button 'Upload'

      expect(page).to have_text 'User import started; this job will run in the background'
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

  context 'when the file fails to upload' do
    before do
      allow_any_instance_of(UploadUserList).to receive(:call).and_raise(Aws::S3::Errors::ServiceError.new('foo', 'bar'))
    end

    scenario 'displays an error' do
      visit new_admin_user_bulk_import_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users.csv')
      click_button 'Upload'

      expect(page).to have_text 'There was a problem uploading the file'
    end
  end
end

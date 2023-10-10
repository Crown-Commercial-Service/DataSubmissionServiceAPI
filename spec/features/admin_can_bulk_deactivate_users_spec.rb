require 'rails_helper'

RSpec.feature 'Admin can bulk deactivate users' do
  let!(:supplier) { FactoryBot.create(:supplier, salesforce_id: '001b000003FAKEFAKE') }

  let!(:user) { FactoryBot.create(:user, name: 'User One', email: 'email_one@ccs.co.uk', suppliers: [supplier]) }

  before do
    sign_in_as_admin
    stub_auth0_token_request
    stub_auth0_delete_user_request(user)
  end

  context 'with a valid CSV' do
    scenario 'deactivates users with specified email addresses' do
      visit admin_users_path
      click_link 'Bulk deactivate users'

      expect(page).to have_text 'Bulk deactivate users'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users-to-offboard.csv')
      click_button 'Upload'

      expect(page).to have_text 'Successfully deactivated users'
    end
  end

  context 'with a CSV with missing or incorrect columns' do
    scenario 'displays an error, showing which columns are missing' do
      visit new_admin_user_bulk_deactivate_path

      attach_file 'Choose', Rails.root.join(
        'spec', 'fixtures', 'suppliers-to-offboard-from-frameworks.csv'
      )
      click_button 'Upload'

      expect(page).to have_text 'Missing headers in CSV file: email'
    end
  end

  context 'with a non-CSV file' do
    scenario 'displays an error' do
      visit new_admin_user_bulk_deactivate_path

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'not-really-an.xls')
      click_button 'Upload'

      expect(page).to have_text 'Uploaded file is not a CSV file'
    end
  end

  context 'without attaching a file' do
    scenario 'displays an error' do
      visit new_admin_user_bulk_deactivate_path

      click_button 'Upload'

      expect(page).to have_text 'Please choose a file to upload'
    end
  end
end
